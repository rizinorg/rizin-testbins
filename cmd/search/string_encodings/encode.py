#!/usr/bin/env python3

from pathlib import Path

encodings = [
    ("utf_16_be", "utf16be"),
    ("utf_16_le", "utf16le"),
    ("utf_32_be", "utf32be"),
    ("utf_32_le", "utf32le"),
    ("cp037", "ibm037")
]

for file in Path(".").iterdir():
    if file.suffix == ".py":
        continue
    p = Path(file)
    with open(p) as f:
        content = f.read()

    for enc in encodings:
        new_file = f"{p.name.split(".")[0]}.{enc[1]}"
        try:
            enc_content = content.encode(enc[0])
            if "utf_16_le" in enc:
                print(enc_content)
            print(enc_content)
        except UnicodeEncodeError:
            print(f"Skip {enc}")
            continue
        with open(new_file, "wb+") as f:
            f.write(enc_content)
            print(f"Wrote: {new_file}")
