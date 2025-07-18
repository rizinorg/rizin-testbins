#!/usr/bin/env python3
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "faker",
# ]
# ///

# -*- coding: utf-8 -*-

# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-FileCopyrightText: 2025 Kagi Assistant <assistant@kagi.com>
# SPDX-License-Identifier: MIT

import argparse
import os
import random
from faker import Faker

SUPPORTED_LOCALES = {
    "en": "English",
    "zh_CN": "Chinese (Simplified)",
    "ja": "Japanese",
    "ru": "Russian",
    "ar": "Arabic",
    "de": "German",
    "es": "Spanish",
    "fr": "French",
    "hi": "Hindi",
    "ko": "Korean",
}

def enc_padding(enc) -> int:
    match enc:
        case "utf-8":
            return 1
        case "utf-16-be" | "utf-16-le":
            return 2
        case "utf-32-be" | "utf-32-le":
            return 4
        case _:
            raise ValueError(f"{enc} not handled.")


def generate_dummy_file(file_path, encodings, target_size, locale="en", noise=False):
    """
    Generate a file filled with locale-specific dummy text
    """
    fake = Faker(locale)
    max_words_per_chunk = 500
    output_files = list()
    for enc in encodings:
        pad = enc_padding(enc)
        output_files.append((enc, pad, open(file_path + "." + enc, "wb")))

    written_size = 0
    while written_size < target_size:
        chunk = " ".join(fake.words(nb=random.randint(0, max_words_per_chunk))) + "\n"
        max_chunk_size = 0
        noise_size = random.randint(0, max_words_per_chunk)
        for encoding, pad, f in output_files:
            bchunk = chunk.encode(encoding)
            chunk_size = len(bchunk)
            f.write(bchunk)
            max_chunk_size = max(max_chunk_size, chunk_size)

            if noise:
                noise_size += (noise_size % pad)
                f.write(random.randbytes(noise_size))
        if noise:
            written_size += noise_size
        written_size += max_chunk_size

        if written_size % (10 * 1024 * 1024) < max_chunk_size:
            print(f"Progress: {written_size / target_size * 100:.1f}%", end="\r")
    print()
    for _, _, f in output_files:
        f.close()


def parse_size(size_str):
    """Convert size string (like '10MB' or '1GB') to bytes"""
    size_str = size_str.upper()
    units = {"GB": 1024**3, "MB": 1024**2, "KB": 1024}
    for unit, multiplier in units.items():
        if unit in size_str:
            return int(float(size_str.replace(unit, "")) * multiplier)
        else:
            ValueError(
                f"Unrecognized size '{size_str}'. It must end with KB, MB, or GB."
            )

    return int(size_str)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate dummy text files in various languages"
    )
    parser.add_argument("file_path", help="Output file path")
    parser.add_argument(
        "--encodings",
        default="utf-8",
        help="File encoding",
        nargs="+",
        choices=["utf-8", "utf-16-be", "utf-16-le", "utf-32-be", "utf-32-le"],
    )
    parser.add_argument(
        "--size",
        required=True,
        help="Rough target file size. Supported units: KB, MB, GB",
    )
    parser.add_argument(
        "--locale",
        default="en",
        help=f"Language locale",
        choices=SUPPORTED_LOCALES.keys(),
    )
    parser.add_argument(
        "--noise",
        action="store_true",
        help=f"If set adds random (non-string) data inbetween the text.",
    )

    args = parser.parse_args()
    target_size = parse_size(args.size)

    generate_dummy_file(
        args.file_path, args.encodings, target_size, args.locale, args.noise
    )
