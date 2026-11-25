#!/usr/bin/env python3
"""Create the original quiet spatial double-footstep cue used by v0.8.

Deterministic synthesis only; no recordings or third-party samples. The source
wave is deliberately soft and the in-game 3D player adds distance attenuation.
This cue suggests somebody moving in another room, not an impact/jump scare.
"""
import math
from pathlib import Path
import random
import struct
import wave


def main() -> None:
    rate = 24000
    seconds = 1.6
    rng = random.Random(27110408)
    samples = [0.0] * int(rate * seconds)
    smooth_noise = 0.0
    for i in range(len(samples)):
        t = i / rate
        smooth_noise = 0.87 * smooth_noise + 0.13 * rng.uniform(-1.0, 1.0)
        value = 0.0
        for start, strength in ((0.10, 0.65), (0.76, 0.49)):
            local = t - start
            if 0 <= local < 0.55:
                attack = min(1.0, local / 0.035)
                decay = math.exp(-local * 11.0)
                heel = math.sin(2 * math.pi * 86 * local) * 0.26
                sole = smooth_noise * 0.74
                toe_time = max(0.0, local - 0.11)
                toe = math.sin(2 * math.pi * 141 * toe_time) * math.exp(-toe_time * 19.0) * 0.08 if local >= 0.11 else 0.0
                value += strength * attack * decay * (heel + sole + toe)
        samples[i] = max(-0.3, min(0.3, value))
    target = Path(__file__).resolve().parents[1] / 'prototype/assets/audio/uncertain_steps.wav'
    with wave.open(str(target), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(rate)
        output.writeframes(b''.join(struct.pack('<h', round(value * 32767)) for value in samples))
    print(f'{target.name}: {seconds:.1f}s, mono PCM16, {rate}Hz, original deterministic synthesis')


if __name__ == '__main__':
    main()
