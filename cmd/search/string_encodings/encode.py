#!/usr/bin/env python3

from pathlib import Path
import ebcdic

encodings = [
    ("utf_16_be", "utf16be"),
    ("utf_16_le", "utf16le"),
    ("utf_32_be", "utf32be"),
    ("utf_32_le", "utf32le"),
    ("cp037", "ibm037"),
    # Provided by ebcdic package
    ("cp285", "ecbdic_uk"),
    ("cp1140", "ecbdic_us"),
    ("cp1145", "ecbdic_es"),
    ("cp290", "ibm290")
]

for file in Path(".").iterdir():
    language = file.name.split("-")[0]
    input_file_enc = file.suffix.strip(".")
    if input_file_enc not in ["ascii", "utf8"]:
        continue
    print(f"Read {file}")
    p = Path(file)
    with open(p) as f:
        content = f.read()

    for enc in encodings:
        py_enc_id = enc[0]
        to_enc = enc[1]
        new_file = f"{p.name.split(".")[0]}.{to_enc}"
        try:
            enc_content = content.encode(py_enc_id)
        except UnicodeEncodeError as e:
            if language == "Japanese" and to_enc == "ibm290":
                raise e
            print(f"No mapping: {language}.{input_file_enc} -> {to_enc}")
            continue
        with open(new_file, "wb+") as f:
            f.write(enc_content)
            print(f"Wrote: {new_file}")
