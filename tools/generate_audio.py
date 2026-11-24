"""Generate original, subtle prototype sound beds; no sampled reference recordings.

Run with Python 3 from the repository root. Reproducible synthesis, mono 22050 Hz.
"""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "prototype" / "assets" / "audio"
RATE = 22050


def write(name, duration, fn):
    rng = random.Random(271104)
    buffer = bytearray()
    for i in range(int(duration * RATE)):
        t = i / RATE
        v = max(-0.95, min(0.95, fn(t, rng)))
        buffer.extend(struct.pack("<h", int(v * 32767)))
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(buffer)


def wind(t, rng):
    # Periodic low tones and quiet filtered-noise-like texture, no siren imitation.
    envelope = 0.6 + 0.15 * math.sin(2 * math.pi * t / 8)
    hum = sum(math.sin(2 * math.pi * f * t) / (k + 3) for k, f in enumerate([37, 53, 71, 91]))
    return envelope * (0.17 * hum + rng.uniform(-0.06, 0.06))


def structure(duration, intensity, impacts=False):
    """Layer restrained original low tones, creaks and decaying debris pulses."""
    def synth(t, rng):
        envelope = min(1.0, t * 3.5) * min(1.0, (duration - t) * 2.0)
        low = 0.19 * math.sin(2 * math.pi * 38 * t) + 0.10 * math.sin(2 * math.pi * 61 * t)
        creak = 0.08 * math.sin(2 * math.pi * (135 * t + 11 * math.sin(t * 1.7)))
        texture = rng.uniform(-0.045, 0.045)
        pulse = 0.0
        if impacts:
            for onset in (0.12, 0.6, 1.25, 2.0):
                age = t - onset
                if age > 0:
                    pulse += math.exp(-age * 9) * (0.19 * math.sin(2 * math.pi * 53 * age) + rng.uniform(-0.12, 0.12))
        return (envelope * (low + creak + texture) + pulse) * intensity
    return synth


def menu_theme(t, rng):
    """An original, restrained four-note rescue motif over a maritime drone."""
    envelope = max(0.0, math.sin(math.pi * t / 16.0)) ** 0.45
    drone = 0.10 * math.sin(2 * math.pi * 55 * t) + 0.06 * math.sin(2 * math.pi * 82.5 * t)
    melody = 0.0
    for onset, frequency in ((0.6, 110.0), (4.2, 164.81), (8.0, 116.54), (11.7, 146.83)):
        age = t - onset
        if age > 0:
            note = math.exp(-age * 0.68) * min(1.0, age * 1.8)
            melody += note * (0.13 * math.sin(2 * math.pi * frequency * age) + 0.035 * math.sin(2 * math.pi * frequency * 2 * age))
    return envelope * (drone + melody + rng.uniform(-0.008, 0.008))


def rotor(t, rng):
    # Original synthesis of a blade pulse. This is a prototype, not a field recording.
    pulse = (0.5 + 0.5 * math.sin(2 * math.pi * 12 * t)) ** 5
    return 0.14 * math.sin(2 * math.pi * 48 * t) + pulse * (0.13 * math.sin(2 * math.pi * 96 * t) + rng.uniform(-0.12, 0.12))


if __name__ == "__main__":
    write("wind", 8, wind)
    write("radio", 0.28, lambda t, r: (0.14 * math.sin(t * 2 * math.pi * 1150) + r.uniform(-0.08, 0.08)) * math.sin(math.pi * t / 0.28) ** 2)
    write("rescue", 0.9, lambda t, r: 0.19 * math.sin(2 * math.pi * (440 if t < 0.3 else 660) * t) * math.exp(-3 * t) * min(1, t * 40))
    write("flare", 1.5, lambda t, r: (r.uniform(-0.18, 0.18) + 0.04 * math.sin(2 * math.pi * 120 * t)) * math.exp(-2.3 * t) * min(1, t * 30))
    write("rumble", 8, structure(8, 0.3))
    write("quake", 6, structure(6, 0.6))
    write("collapse", 7, structure(7, 0.8, impacts=True))
    write("impact", 4, structure(4, 1.0, impacts=True))
    write("menu_theme", 16, menu_theme)
    write("rotors", 8, rotor)
    write("intro_sting", 3.6, lambda t, r: min(1.0, t * 2) * math.exp(-t * 0.8) * (0.22 * math.sin(2 * math.pi * 55 * t) + 0.09 * math.sin(2 * math.pi * 82.5 * t) + 0.025 * math.sin(2 * math.pi * 660 * t)))
    print("Created eleven original WAV assets in prototype/assets/audio")
