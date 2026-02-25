#!/usr/bin/env python3
"""
Generate exercise illustration images via Gemini Imagen API.

Reads prompts from docs/image_prompts.md and generates two formats per step:
  - *_sq.jpg  → 1:1  square  (used for thumbnail widgets)
  - *_ls.jpg  → 16:9 landscape (used for the detail-sheet banner)

Usage:
    export GEMINI_API_KEY=AIza...
    python3 scripts/generate_images.py

Output: assets/images/exercises/{exerciseType}_{step:02d}_{format}.jpg
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
    "/models/gemini-2.5-flash-image:generateContent"
)
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "images" / "exercises"
PROMPTS_FILE = Path(__file__).parent.parent / "docs" / "image_prompts.md"

GLOBAL_STYLE = (
    "Minimalist calisthenics exercise illustration for a fitness app. "
    "Smooth, slightly volumetric white figure with subtle grey shading on a "
    "solid deep-charcoal background (#1C1C1C). No rounded corners, no border, "
    "no frame, no vignette. Orange (#FF5722) curved motion arrows with "
    "arrowheads showing movement direction; orange accent stripe or glow on "
    "the primary working muscles or joints. Simple flat light-grey structural "
    "prop only when essential (wall face, horizontal bar, or thin floor line). "
    "No face details, no text, no labels. Bold, high-contrast, "
    "vector-render style. "
)

# Seconds to wait between API calls to avoid rate-limiting
REQUEST_DELAY = 2


# ── Parse prompts from markdown ───────────────────────────────────────────────

def parse_prompts(md_path: Path) -> list[dict]:
    """
    Returns a list of dicts: {"filename": "pushUp_01_sq.jpg", "prompt": "..."}.

    Parses blocks of the form:
        ### pushUp_01_sq.jpg — 壁上推 Wall Push-up (方形)
        ```
        ...prompt text...
        ```
    Filenames ending in _sq.jpg get aspectRatio "1:1".
    Filenames ending in _ls.jpg get aspectRatio "16:9".
    """
    text = md_path.read_text(encoding="utf-8")
    # Match  ### filename.jpg — ... \n ``` \n <prompt> \n ```
    pattern = re.compile(
        r"###\s+([\w]+\.jpg)[^\n]*\n```\n(.*?)\n```",
        re.DOTALL,
    )
    entries = []
    for m in pattern.finditer(text):
        filename = m.group(1)
        prompt = " ".join(m.group(2).split())  # collapse whitespace
        if filename.endswith("_ls.jpg"):
            aspect = "16:9"
        else:
            aspect = "1:1"
        entries.append({
            "filename": filename,
            "prompt": prompt,
            "aspect": aspect,
        })
    return entries


# ── Gemini Imagen API call ────────────────────────────────────────────────────

def generate_image(prompt: str, aspect: str) -> bytes:
    """Call Gemini 2.5 Flash Image and return JPEG bytes."""
    full_prompt = GLOBAL_STYLE + prompt
    payload = {
        "contents": [{"parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": aspect},
        },
    }
    resp = requests.post(
        IMAGEN_URL,
        params={"key": API_KEY},
        json=payload,
        timeout=120,
    )
    if resp.status_code != 200:
        raise RuntimeError(
            f"API error {resp.status_code}: {resp.text[:300]}"
        )
    data = resp.json()
    parts = data["candidates"][0]["content"]["parts"]
    for part in parts:
        if "inlineData" in part:
            raw = base64.b64decode(part["inlineData"]["data"])
            mime = part["inlineData"].get("mimeType", "image/png")
            # Response may be PNG; convert to JPEG so filenames stay *.jpg
            if mime != "image/jpeg":
                from PIL import Image
                import io as _io
                img = Image.open(_io.BytesIO(raw)).convert("RGB")
                buf = _io.BytesIO()
                img.save(buf, format="JPEG", quality=90)
                return buf.getvalue()
            return raw
    raise RuntimeError("No image data in response")


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
        aspect   = entry["aspect"]
        out_path = OUTPUT_DIR / filename

        if out_path.exists():
            print(f"[{i:03d}/{len(entries)}] SKIP  {filename}  (already exists)")
            success += 1
            continue

        print(
            f"[{i:03d}/{len(entries)}] GEN   {filename} [{aspect}] ...",
            end=" ",
            flush=True,
        )
        try:
            image_bytes = generate_image(entry["prompt"], aspect)
            out_path.write_bytes(image_bytes)
            print(f"OK ({len(image_bytes) // 1024} KB)")
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
