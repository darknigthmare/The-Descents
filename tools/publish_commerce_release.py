#!/usr/bin/env python3
"""Package and publish only an explicitly reviewed v0.12 candidate in Actions.

The only trigger is a push changing .review/v0.12/release-request.json alone.
That commit must have exactly one parent, approved_commit, which already
contains the explicit reviews and all nine reviewed document page images.
The expected remote HEAD is GITHUB_SHA (the release-request commit); it cannot
be embedded in its own JSON. request_commit below means the candidate request.

RELEASE REQUEST CONTRACT (all keys required, no additional keys)
  format: 1; version: "0.12.0"; phase: "release"; request_id: short identifier
  approved_commit: complete lowercase Git SHA of the reviewed parent
  candidate_run_id: positive integer; candidate_artifact_id: positive integer
  candidate_artifact_name: "tower-descent-v012-candidate-" + request_commit
  request_commit: complete SHA of the isolated candidate-request commit
  source_commit: complete SHA of that candidate request's sole parent
  candidate_sha256: SHA256 of the original retained CANDIDATE.json
  runtime_sha256: exact qa_common.runtime_hashes() dictionary
  reviews_sha256: {
    "docs/validation/v0.12/VISUAL_REVIEW.json": "<lowercase SHA256>",
    "docs/validation/v0.12/DOCUMENT_REVIEW.json": "<lowercase SHA256>"
  }

Commands: guard, prepare, publish; --describe-request only prints this contract.
All other commands require the configured GitHub Actions push context.
prepare downloads the artifact by numeric ID and verifies its API provenance
and ZIP digest before extracting into a temporary directory. It preserves the
approved reviews, DOCUMENT_CONTENT.json and document-pages/ from Git, even if
the candidate artifact contains older copies. CANDIDATE.json is never edited.
It requires verify_commerce_release.py --evidence-only, mirrors builds/web to
dist, runs package_release.py and then requires the full release verifier.
publish repeats the final gate and pushes only allowed generated paths, with
two remote-HEAD checks and a normal, non-forced single-branch Git push.
No review, approval, release request, tag or GitHub Release is generated.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from zipfile import ZipFile

from qa_common import MAX_ARCHIVE_BYTES, ROOT, git_head, runtime_hashes, sha256, version


VERSION = "0.12.0"
REPOSITORY = "darknigthmare/The-Descents"
BRANCH = "feat/live-tower-collapse"
TARGET = "refs/heads/" + BRANCH
WORKFLOW = ".github/workflows/commerce-review.yml"
REQUEST = ".review/v0.12/release-request.json"
CANDIDATE_REQUEST = ".review/v0.12/candidate-request.json"
VALIDATION = "docs/validation/v0.12/"
CAPTURES = "docs/captures/v0.12/"
CANDIDATE = VALIDATION + "CANDIDATE.json"
REVIEWS = (VALIDATION + "VISUAL_REVIEW.json", VALIDATION + "DOCUMENT_REVIEW.json")
DOCUMENT_EVIDENCE = {VALIDATION + "DOCUMENT_CONTENT.json"} | {
    VALIDATION + f"document-pages/page-{page}.png" for page in range(1, 10)
}
PRESERVED = set(REVIEWS) | DOCUMENT_EVIDENCE
DOCUMENT_INPUTS = {
    "docs/CONTINUATION_A22_A20_V0.12.md", "tools/build_commerce_document.py",
    "docs/The-Tower-Descent-Continuation-v0.12.docx",
    "docs/The-Tower-Descent-Continuation-v0.12.pdf",
}
TECHNICAL_JSON = {
    "CANDIDATE.json", "CANDIDATE_REQUEST_GUARD.json", "CANDIDATE_EXPORTS.json",
    "CANDIDATE_TEMPLATES.json", "CANDIDATE_VULKAN.json", "VERIFICATION.json",
    "EXPORTED_PACK_VERIFICATION.json",
}
TECHNICAL_LOG = re.compile(
    r"(?:final-[a-z0-9_]+|exported-(?:windows|web)|candidate-(?:run_validation|"
    r"verify_exported_packs|fetch_export_templates|export-windows|export-web|"
    r"native-compatibility|native-forward_plus|vulkan-probe))\.txt"
)
PUBLISH_DIRS = ("dist", VALIDATION.rstrip("/"), CAPTURES.rstrip("/"))
RELEASE_FILES = tuple(f"releases/The-Tower-Descent-v0.12-{role}.zip"
                      for role in ("Windows-x64", "Sources", "Captures-native")) + (
    "releases/SHA256SUMS.txt", "releases/VERIFICATION_V0.12.json",
)
BUILD_DIRS = ("builds/windows", "builds/web")
SHA = re.compile(r"[0-9a-f]{64}")
COMMIT = re.compile(r"[0-9a-f]{40}")
MAX_ARTIFACT_BYTES = 1024 * 1024 * 1024
MAX_EXPANDED_BYTES = 2 * MAX_ARTIFACT_BYTES
MAX_MEMBER_BYTES = 512 * 1024 * 1024


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def object_pairs(pairs: list[tuple[str, object]]) -> dict:
    result = {}
    for key, value in pairs:
        require(key not in result, "Duplicate JSON key: " + key)
        result[key] = value
    return result


def json_object(data: str | bytes) -> dict:
    value = json.loads(data, object_pairs_hook=object_pairs)
    require(isinstance(value, dict), "Expected a JSON object.")
    return value


def read_json(path: Path) -> dict:
    return json_object(path.read_bytes())


def canonical(name: object) -> str:
    require(isinstance(name, str) and bool(name) and not any(c in name for c in ("\\", "\0", ":")),
            "Invalid repository-relative path.")
    parsed = PurePosixPath(name)
    require(not parsed.is_absolute() and ".." not in parsed.parts and parsed.as_posix() == name,
            "Noncanonical repository-relative path: " + name)
    return name


def local_path(name: str, *, must_exist: bool = True) -> Path:
    path = ROOT / canonical(name)
    require(not any(part.is_symlink() for part in (path, *path.parents) if part != ROOT.parent),
            "Linked paths are forbidden: " + name)
    require(path.resolve().is_relative_to(ROOT.resolve()), "Path escapes the checkout: " + name)
    if must_exist:
        require(path.is_file(), "Required file is absent: " + name)
    return path


def record(name: str) -> dict:
    path = local_path(name)
    return {"file": name, "bytes": path.stat().st_size, "sha256": sha256(path)}


def git(*arguments: str) -> str:
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def committed_sha(commit: str, name: str) -> str:
    data = subprocess.check_output(["git", "show", commit + ":" + canonical(name)], cwd=ROOT)
    return hashlib.sha256(data).hexdigest()


def request_schema(request: dict) -> None:
    expected = {"format", "version", "phase", "request_id", "approved_commit", "candidate_run_id",
                "candidate_artifact_id", "candidate_artifact_name", "request_commit", "source_commit",
                "candidate_sha256", "runtime_sha256", "reviews_sha256"}
    require(set(request) == expected, "Release request has missing or unexpected fields; use --describe-request.")
    require(type(request["format"]) is int and request["format"] == 1 and request["version"] == VERSION
            and request["phase"] == "release", "Invalid release request format, phase or version.")
    require(isinstance(request["request_id"], str)
            and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,79}", request["request_id"]) is not None,
            "Invalid release request identifier.")
    for key in ("approved_commit", "request_commit", "source_commit"):
        require(isinstance(request[key], str) and COMMIT.fullmatch(request[key]) is not None,
                "Expected a complete lowercase Git SHA: " + key)
    for key in ("candidate_run_id", "candidate_artifact_id"):
        require(type(request[key]) is int and request[key] > 0, "Expected a positive integer: " + key)
    require(request["candidate_artifact_name"] == "tower-descent-v012-candidate-" + request["request_commit"],
            "Artifact name must identify the exact candidate request commit.")
    require(isinstance(request["candidate_sha256"], str) and SHA.fullmatch(request["candidate_sha256"]) is not None,
            "Candidate SHA256 is malformed.")
    reviews = request["reviews_sha256"]
    require(isinstance(reviews, dict) and set(reviews) == set(REVIEWS)
            and all(isinstance(value, str) and SHA.fullmatch(value) is not None for value in reviews.values()),
            "Pin both explicit reviews by their exact SHA256.")
    runtime = request["runtime_sha256"]
    require(isinstance(runtime, dict) and bool(runtime), "The complete runtime dictionary is required.")
    for name, digest in runtime.items():
        require(canonical(name).startswith("prototype/") and isinstance(digest, str)
                and SHA.fullmatch(digest) is not None, "Invalid runtime fingerprint.")


def check_approved_files(request: dict) -> None:
    for name in sorted(PRESERVED | DOCUMENT_INPUTS):
        actual = record(name)["sha256"]
        require(actual == committed_sha(request["approved_commit"], name),
                "Approved evidence is missing from its parent or changed: " + name)
        if name in request["reviews_sha256"]:
            require(actual == request["reviews_sha256"][name], "Explicit review fingerprint differs: " + name)
    for name in REVIEWS:
        review = read_json(local_path(name))
        require(review.get("format") == 1 and review.get("version") == VERSION and review.get("all_pass") is True
                and all(review.get(key) == request[key] for key in ("request_commit", "source_commit")),
                "Explicit review refers to another candidate or is incomplete: " + name)
    visual = read_json(local_path(REVIEWS[0]))
    require(visual.get("candidate_sha256") == request["candidate_sha256"]
            and visual.get("runtime_sha256") == request["runtime_sha256"],
            "Visual review and release request identify different frozen candidates.")


def guard(*, pristine: bool = False) -> dict:
    require(os.environ.get("GITHUB_ACTIONS") == "true" and os.environ.get("GITHUB_EVENT_NAME") == "push",
            "This command is restricted to the configured Actions push workflow.")
    require(os.environ.get("GITHUB_REPOSITORY", "").lower() == REPOSITORY.lower()
            and os.environ.get("GITHUB_REF") == TARGET, "Only the existing project branch can be published.")
    head = git_head()
    require(os.environ.get("GITHUB_SHA") == head, "Checkout is not the triggering release request commit.")
    request = read_json(local_path(REQUEST))
    request_schema(request)
    require(version() == VERSION, "The project does not identify version 0.12.0.")
    require(git("rev-list", "--parents", "-n", "1", "HEAD").split() == [head, request["approved_commit"]],
            "Release request must be a single-parent child of approved_commit.")
    changed = git("diff", "--name-only", "--no-renames", request["approved_commit"], head).splitlines()
    require(changed == [REQUEST], "Commit release-request.json alone after committing the explicit reviews.")
    require(committed_sha(head, REQUEST) == record(REQUEST)["sha256"], "Release request differs from its committed bytes.")
    require(git("rev-list", "--parents", "-n", "1", request["request_commit"]).split()
            == [request["request_commit"], request["source_commit"]], "Candidate request has the wrong source parent.")
    require(subprocess.run(["git", "merge-base", "--is-ancestor", request["request_commit"], request["approved_commit"]],
                           cwd=ROOT).returncode == 0, "Approved parent does not descend from the candidate request.")
    require(committed_sha(request["request_commit"], CANDIDATE_REQUEST) == record(CANDIDATE_REQUEST)["sha256"],
            "Candidate request changed after generation.")
    require(runtime_hashes() == request["runtime_sha256"], "Runtime differs from the reviewed exact dictionary.")
    check_approved_files(request)
    if pristine:
        require(not git("status", "--porcelain=v1", "--untracked-files=all"), "Start from a clean release-request checkout.")
    return request


def gh_json(endpoint: str) -> dict:
    data = subprocess.check_output(["gh", "api", "--hostname", "github.com", "--method", "GET", endpoint,
                                    "-H", "Accept: application/vnd.github+json"], cwd=ROOT, timeout=90)
    return json_object(data)


def check_artifact_metadata(request: dict, artifact: dict, run: dict) -> str:
    require(artifact.get("id") == request["candidate_artifact_id"]
            and artifact.get("name") == request["candidate_artifact_name"] and artifact.get("expired") is False,
            "Artifact identity differs or its retention has expired.")
    require(run.get("id") == request["candidate_run_id"] and run.get("status") == "completed"
            and run.get("conclusion") == "success" and run.get("event") == "push"
            and run.get("path") == WORKFLOW and run.get("head_sha") == request["request_commit"]
            and run.get("head_branch") == BRANCH, "Candidate run is not the successful configured push workflow.")
    repository = run.get("repository", {})
    head_repository = run.get("head_repository", {})
    require(str(repository.get("full_name", "")).lower() == REPOSITORY.lower()
            and str(head_repository.get("full_name", "")).lower() == REPOSITORY.lower()
            and type(repository.get("id")) is int and repository["id"] == head_repository.get("id"),
            "Candidate run belongs to another repository or fork.")
    linked = artifact.get("workflow_run", {})
    require(linked.get("id") == run["id"] and linked.get("head_sha") == request["request_commit"]
            and linked.get("head_branch") == BRANCH and linked.get("repository_id") == repository["id"]
            and linked.get("head_repository_id") == repository["id"], "Artifact belongs to another workflow run.")
    require(type(artifact.get("size_in_bytes")) is int and 0 < artifact["size_in_bytes"] <= MAX_ARTIFACT_BYTES,
            "Candidate artifact has an invalid or excessive size.")
    digest = artifact.get("digest", "")
    require(isinstance(digest, str) and re.fullmatch(r"sha256:[0-9a-f]{64}", digest) is not None,
            "The retained upload-artifact v4 ZIP must have its API SHA256 digest.")
    return digest.removeprefix("sha256:")


def technical_file(name: str) -> bool:
    if not name.startswith(VALIDATION):
        return False
    basename = name[len(VALIDATION):]
    return basename in TECHNICAL_JSON or TECHNICAL_LOG.fullmatch(basename) is not None


def allowed_artifact_file(name: str) -> bool:
    return name == CANDIDATE_REQUEST or name in PRESERVED or technical_file(name) \
        or name.startswith(CAPTURES) or any(name.startswith(folder + "/") for folder in BUILD_DIRS)


def extract_artifact(archive: Path, destination: Path) -> None:
    """Inspect every member before writing; never follow links or use extractall."""
    with ZipFile(archive) as zipped:
        infos = zipped.infolist()
        require(0 < len(infos) <= 10000, "Candidate ZIP has an invalid member count.")
        names, expanded = set(), 0
        files = []
        for info in infos:
            raw = info.filename
            require(info.orig_filename == raw and "\0" not in raw, "Candidate ZIP has an ambiguous filename.")
            name = canonical(raw[:-1] if info.is_dir() else raw)
            require(name.casefold() not in names, "Candidate ZIP has a duplicated path: " + name)
            names.add(name.casefold())
            mode = stat.S_IFMT(info.external_attr >> 16)
            require(mode in (0, stat.S_IFREG, stat.S_IFDIR) and not (info.flag_bits & 1),
                    "Linked, special or encrypted artifact member: " + name)
            if info.is_dir():
                require(mode in (0, stat.S_IFDIR), "Invalid ZIP directory mode.")
                continue
            require(mode in (0, stat.S_IFREG) and allowed_artifact_file(name), "Unexpected candidate artifact path: " + name)
            require(0 <= info.file_size <= MAX_MEMBER_BYTES, "Artifact member exceeds its size limit: " + name)
            expanded += info.file_size
            require(expanded <= MAX_EXPANDED_BYTES, "Expanded artifact exceeds its size limit.")
            files.append((info, name))
        for info, name in files:
            target = destination / name
            target.parent.mkdir(parents=True, exist_ok=True)
            with zipped.open(info) as source, target.open("xb") as output:
                shutil.copyfileobj(source, output, 1024 * 1024)
            require(target.stat().st_size == info.file_size, "Extracted member size differs: " + name)


def download_candidate(request: dict, temporary: Path) -> tuple[Path, dict]:
    base = "repos/" + REPOSITORY + "/actions/"
    artifact = gh_json(base + "artifacts/" + str(request["candidate_artifact_id"]))
    run = gh_json(base + "runs/" + str(request["candidate_run_id"]))
    digest = check_artifact_metadata(request, artifact, run)
    archive = temporary / "candidate.zip"
    with archive.open("xb") as output:
        subprocess.run(["gh", "api", "--hostname", "github.com", "--method", "GET",
                        base + "artifacts/" + str(request["candidate_artifact_id"]) + "/zip"],
                       cwd=ROOT, stdout=output, check=True, timeout=600)
    require(archive.stat().st_size == artifact["size_in_bytes"] and sha256(archive) == digest,
            "Downloaded ZIP differs from the artifact API size or SHA256.")
    extracted = temporary / "extracted"
    extracted.mkdir()
    extract_artifact(archive, extracted)
    require((extracted / CANDIDATE).is_file() and sha256(extracted / CANDIDATE) == request["candidate_sha256"],
            "Retained CANDIDATE.json differs from the explicitly approved bytes.")
    candidate = read_json(extracted / CANDIDATE)
    require(candidate.get("version") == VERSION and candidate.get("stage") == "complete"
            and candidate.get("automated_steps_passed") is True
            and all(candidate.get(key) == request[key] for key in ("request_commit", "source_commit", "runtime_sha256")),
            "Candidate metadata differs from the release request.")
    require((extracted / CANDIDATE_REQUEST).is_file()
            and sha256(extracted / CANDIDATE_REQUEST) == record(CANDIDATE_REQUEST)["sha256"],
            "Artifact candidate request differs from its committed request.")
    return extracted, {"run_id": run["id"], "artifact_id": artifact["id"], "name": artifact["name"],
                       "zip_bytes": archive.stat().st_size, "zip_sha256": digest,
                       "request_commit": candidate["request_commit"], "source_commit": candidate["source_commit"]}


def replace_tree(source: Path, name: str) -> None:
    require(source.is_dir(), "Candidate output directory is absent: " + name)
    destination = local_path(name, must_exist=False)
    if destination.exists():
        require(destination.is_dir(), "Expected an output directory: " + name)
        shutil.rmtree(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source, destination)


def restore_candidate(extracted: Path) -> None:
    for name in (*BUILD_DIRS, CAPTURES.rstrip("/")):
        replace_tree(extracted / name, name)
    validation = local_path(VALIDATION.rstrip("/"), must_exist=False)
    validation.mkdir(parents=True, exist_ok=True)
    # Only technical candidate outputs are replaced. Reviews and documentary
    # evidence remain the exact files already committed in approved_commit.
    for path in validation.iterdir():
        name = path.relative_to(ROOT).as_posix()
        if technical_file(name):
            local_path(name).unlink()
    for path in sorted((extracted / VALIDATION).iterdir()):
        name = VALIDATION + path.name
        if technical_file(name):
            shutil.copyfile(path, local_path(name, must_exist=False))


def run_tool(name: str, *arguments: str) -> None:
    subprocess.run([sys.executable, str(local_path("tools/" + name)), *arguments], cwd=ROOT, check=True, timeout=900)


def output_records() -> list[dict]:
    names = set(RELEASE_FILES)
    for folder in (*PUBLISH_DIRS, *BUILD_DIRS):
        directory = local_path(folder, must_exist=False)
        require(directory.is_dir(), "Generated output directory is absent: " + folder)
        names.update(path.relative_to(ROOT).as_posix() for path in directory.rglob("*") if path.is_file())
    return [record(name) for name in sorted(names)]


def allowed_publication(name: str) -> bool:
    return name in RELEASE_FILES or technical_file(name) or name.startswith(CAPTURES) or name.startswith("dist/")


def check_mutations() -> None:
    changed = git("diff", "--name-only", "--no-renames", "HEAD").splitlines()
    changed += git("ls-files", "--others", "--exclude-standard").splitlines()
    require(all(allowed_publication(name) for name in changed), "A change outside generated release outputs would be published.")


def state_path() -> Path:
    directory = Path(os.environ.get("RUNNER_TEMP", ""))
    require(directory.is_absolute() and directory.is_dir() and not directory.resolve().is_relative_to(ROOT.resolve()),
            "RUNNER_TEMP must be a real directory outside the checkout.")
    path = directory / "tower-descent-v012-release-state.json"
    require(not path.is_symlink(), "Release state cannot be a symlink.")
    return path


def prepare() -> None:
    request = guard(pristine=True)
    require(bool(os.environ.get("GH_TOKEN")), "GH_TOKEN is required to read the exact Actions artifact.")
    state = state_path()
    if state.exists():
        state.unlink()
    with tempfile.TemporaryDirectory(prefix="tower-v012-candidate-", dir=state.parent) as directory:
        extracted, artifact = download_candidate(request, Path(directory))
        restore_candidate(extracted)
    check_approved_files(request)
    require(sha256(local_path(CANDIDATE)) == request["candidate_sha256"], "Candidate changed during restoration.")
    run_tool("verify_commerce_release.py", "--evidence-only")
    replace_tree(local_path("builds/web", must_exist=False), "dist")
    run_tool("package_release.py")
    run_tool("verify_commerce_release.py")
    guard()
    check_mutations()
    report = read_json(local_path("releases/VERIFICATION_V0.12.json"))
    require(report.get("status") == "PASS" and report.get("verified_checkout") == git_head(),
            "Final release verification is absent or identifies another checkout.")
    value = {"format": 1, "version": VERSION, "release_request_commit": git_head(),
             "release_request_sha256": record(REQUEST)["sha256"], "approved_commit": request["approved_commit"],
             "publisher_sha256": sha256(Path(__file__).resolve()), "artifact": artifact, "outputs": output_records()}
    state.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PREPARED", "candidate_run_id": artifact["run_id"],
                      "candidate_artifact_id": artifact["artifact_id"], "approval_generated": False, "published": False}))


def remote_head() -> str:
    ref = gh_json("repos/" + REPOSITORY + "/git/ref/heads/" + BRANCH)
    obj = ref.get("object", {})
    require(ref.get("ref") == TARGET and obj.get("type") == "commit"
            and COMMIT.fullmatch(str(obj.get("sha", ""))) is not None, "The existing publication branch is unavailable.")
    return obj["sha"]


def publish() -> None:
    request = guard()
    require(bool(os.environ.get("GH_TOKEN")), "GH_TOKEN is required for the guarded branch publication.")
    expected = git_head()
    prepared = read_json(state_path())
    require(prepared.get("format") == 1 and prepared.get("version") == VERSION
            and prepared.get("release_request_commit") == expected
            and prepared.get("release_request_sha256") == record(REQUEST)["sha256"]
            and prepared.get("approved_commit") == request["approved_commit"]
            and prepared.get("publisher_sha256") == sha256(Path(__file__).resolve()),
            "Prepared delivery state does not identify this isolated request and publisher.")
    require(prepared.get("outputs") == output_records(), "Generated delivery files changed after their passing gate.")
    require(not git("diff", "--cached", "--name-only"), "The index must be empty before release staging.")
    check_mutations()
    run_tool("verify_commerce_release.py")
    guard()
    check_mutations()
    if remote_head() != expected:
        print("Branch advanced; verified outputs remain in the workflow artifact. No commit or push attempted.")
        return
    for command in (("remote", "get-url", "origin"), ("remote", "get-url", "--push", "origin")):
        require(git(*command).rstrip("/").removesuffix(".git").lower() == ("https://github.com/" + REPOSITORY).lower(),
                "Origin must target this repository over HTTPS.")
    paths = [*PUBLISH_DIRS, *RELEASE_FILES]
    git("add", "--", *paths)
    staged = git("diff", "--cached", "--name-only", "--no-renames").splitlines()
    require(bool(staged) and all(allowed_publication(name) for name in staged), "Unexpected or empty release staging scope.")
    for name in staged:
        path = ROOT / name
        if path.is_file():
            require(path.stat().st_size < MAX_ARCHIVE_BYTES, "Generated Git member reaches the exclusive 100 MiB limit: " + name)
    require(git_head() == expected, "Local HEAD advanced before publication.")
    git("config", "user.name", "github-actions[bot]")
    git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
    git("commit", "-m", "Publish reviewed v0.12 from source " + request["source_commit"][:12])
    published_commit = git_head()
    require(git("rev-list", "--parents", "-n", "1", "HEAD").split() == [published_commit, expected],
            "Publication commit must be a direct child of the release request.")
    if remote_head() != expected:
        print("Branch advanced before push; the generated commit stays local and the workflow artifact is retained.")
        return
    # gh reads GH_TOKEN from the environment; no token is written to a file or
    # passed on the command line. A racing remote update rejects this normal push.
    result = subprocess.run(["git", "-c", "credential.helper=", "-c", "credential.helper=!gh auth git-credential",
                             "push", "origin", "HEAD:" + TARGET], cwd=ROOT, timeout=180)
    if result.returncode:
        require(remote_head() != expected, "Git push failed while the requested branch was unchanged.")
        print("Branch changed during publication; no force push was attempted. Use the retained workflow artifact.")
        return
    print(json.dumps({"status": "PUBLISHED", "branch": BRANCH, "commit": published_commit,
                      "source_commit": request["source_commit"], "approval_generated": False}))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("guard", "prepare", "publish"), nargs="?")
    parser.add_argument("--describe-request", action="store_true")
    args = parser.parse_args()
    if args.describe_request:
        print(__doc__)
        return 0
    if args.command is None:
        parser.error("choose guard, prepare or publish")
    try:
        if args.command == "guard":
            request = guard(pristine=True)
            print(json.dumps({"status": "GUARD_PASS", "version": VERSION, "approved_commit": request["approved_commit"],
                              "release_request_commit": git_head(), "candidate_request_commit": request["request_commit"]}))
        elif args.command == "prepare":
            prepare()
        else:
            publish()
        return 0
    except (RuntimeError, OSError, ValueError, subprocess.SubprocessError) as error:
        print("Release refused: " + str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
