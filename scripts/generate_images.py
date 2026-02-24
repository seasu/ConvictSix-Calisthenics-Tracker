#!/usr/bin/env python3
"""
Generate exercise illustration images via Gemini Imagen API.

Usage:
    export GEMINI_API_KEY=AIza...
    python3 scripts/generate_images.py

Output: assets/images/exercises/{exerciseType}_{step:02d}.jpg
"""

import base64
import os
import re
import sys
import time
from pathlib import Path

import requests

# ── Config ────────────────────────────────────────────────────────────────────

API_KEY = os.environ.get("GEMINI_API_KEY", "")
IMAGEN_URL = (
    "https://generativelanguage.googleapis.com/v1beta"
    "/models/imagen-3.0-generate-001:predict"
)
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "images" / "exercises"
PROMPTS_FILE = Path(__file__).parent.parent / "docs" / "image_prompts.md"

GLOBAL_STYLE = (
    "Flat design athletic illustration, minimalist cartoon figure "
    "(gender-neutral), dark background color #111111, figure in white/light "
    "grey, orange accent color #FF5722 used for motion arrows or highlights, "
    "simple bold shapes with no facial details, clean confident lines, sports "
    "training app icon style, square 1:1 format, no text or labels. "
)

# Seconds to wait between API calls to avoid rate-limiting
REQUEST_DELAY = 2


# ── Parse prompts from markdown ───────────────────────────────────────────────

def parse_prompts(md_path: Path) -> list[dict]:
    """
    Returns a list of dicts: {"filename": "pushUp_01.jpg", "prompt": "..."}.
    Parses blocks of the form:
        ### pushUp_01.jpg — 壁上推 Wall Push-up
        ```
        ...prompt text...
        ```
    """
    text = md_path.read_text(encoding="utf-8")
    # Match  ### filename.jpg — ... \n ``` \n <prompt> \n ```
    pattern = re.compile(
        r"###\s+(\w+_\d{2}\.jpg)[^\n]*\n```\n(.*?)\n```",
        re.DOTALL,
    )
    entries = []
    for m in pattern.finditer(text):
        filename = m.group(1)
        prompt = " ".join(m.group(2).split())  # collapse whitespace
        entries.append({"filename": filename, "prompt": prompt})
    return entries


# ── Gemini Imagen API call ────────────────────────────────────────────────────

def generate_image(prompt: str) -> bytes:
    """Call Imagen 3 and return raw JPEG bytes."""
    full_prompt = GLOBAL_STYLE + prompt
    payload = {
        "instances": [{"prompt": full_prompt}],
        "parameters": {
            "sampleCount": 1,
            "aspectRatio": "1:1",
        },
    }
    resp = requests.post(
        IMAGEN_URL,
        params={"key": API_KEY},
        json=payload,
        timeout=60,
    )
    if resp.status_code != 200:
        raise RuntimeError(
            f"API error {resp.status_code}: {resp.text[:300]}"
        )
    data = resp.json()
    b64 = data["predictions"][0]["bytesBase64Encoded"]
    return base64.b64decode(b64)


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    if not API_KEY:
        print("ERROR: GEMINI_API_KEY is not set.")
        print("  Run:  export GEMINI_API_KEY=AIza...")
        sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    entries = parse_prompts(PROMPTS_FILE)
    if not entries:
        print("ERROR: No prompts found in", PROMPTS_FILE)
        sys.exit(1)

    print(f"Found {len(entries)} prompts. Starting generation...\n")

    success = 0
    failed = []

    for i, entry in enumerate(entries, 1):
        filename = entry["filename"]
        out_path = OUTPUT_DIR / filename

        if out_path.exists():
            print(f"[{i:02d}/{len(entries)}] SKIP  {filename}  (already exists)")
            success += 1
            continue

        print(f"[{i:02d}/{len(entries)}] GEN   {filename} ...", end=" ", flush=True)
        try:
            image_bytes = generate_image(entry["prompt"])
            out_path.write_bytes(image_bytes)
            print(f"OK ({len(image_bytes)//1024} KB)")
            success += 1
        except Exception as exc:
            print(f"FAIL — {exc}")
            failed.append(filename)

        if i < len(entries):
            time.sleep(REQUEST_DELAY)

    print(f"\nDone: {success}/{len(entries)} images saved to {OUTPUT_DIR}")
    if failed:
        print("Failed:")
        for f in failed:
            print(f"  {f}")
        sys.exit(1)


if __name__ == "__main__":
    main()
