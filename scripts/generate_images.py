#!/usr/bin/env python3
"""
Generate exercise illustration images via Gemini Imagen API.

Reads prompts from docs/image_prompts.md and generates two formats per step:
  - *_sq.jpg  → 1:1  square  (used for thumbnail widgets)
  - *_ls.jpg  → 16:9 landscape (used for the detail-sheet banner)

Usage:
    export GEMINI_API_KEY=AIza...

    # Generate all missing images:
    python3 scripts/generate_images.py

    # Generate all images for one exercise (skip existing):
    python3 scripts/generate_images.py --exercise squat

    # Regenerate specific steps of one exercise (overwrites existing):
    python3 scripts/generate_images.py --exercise squat --steps 1,6,9 --overwrite

    # Regenerate a range of steps across all exercises:
    python3 scripts/generate_images.py --steps 6-10 --overwrite

    # Overwrite everything:
    python3 scripts/generate_images.py --overwrite

Output: assets/images/exercises/{exerciseType}_{step:02d}_{format}.jpg
"""

import argparse
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

VALID_EXERCISES = ["pushUp", "squat", "pullUp", "legRaise", "bridge", "handstand"]

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


# ── Argument parsing ──────────────────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate exercise illustration images via Gemini Imagen API."
    )
    parser.add_argument(
        "--exercise",
        default="all",
        choices=["all"] + VALID_EXERCISES,
        help="Which exercise to generate (default: all)",
    )
    parser.add_argument(
        "--steps",
        default="",
        metavar="STEPS",
        help=(
            "Step numbers to generate, e.g. '1,6,9' or '6-10' or '1-3,8'. "
            "Leave blank to generate all steps."
        ),
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite images that already exist on disk.",
    )
    return parser.parse_args()


def parse_steps(steps_str: str) -> set[int] | None:
    """
    Parse a steps string into a set of ints.
    Returns None when the string is blank (meaning: all steps).

    Supported formats:
      ''          → all steps (returns None)
      '6'         → {6}
      '1,6,9'     → {1, 6, 9}
      '6-10'      → {6, 7, 8, 9, 10}
      '1-3,8,10'  → {1, 2, 3, 8, 10}
    """
    if not steps_str.strip():
        return None
    result: set[int] = set()
    for part in steps_str.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            result.update(range(int(a.strip()), int(b.strip()) + 1))
        else:
            result.add(int(part))
    return result


# ── Parse prompts from markdown ───────────────────────────────────────────────

def parse_prompts(md_path: Path) -> list[dict]:
    """
    Returns a list of dicts:
        {"filename": "pushUp_01_sq.jpg", "prompt": "...", "aspect": "1:1",
         "exercise": "pushUp", "step": 1}

    Parses blocks of the form:
        ### pushUp_01_sq.jpg — 壁上推 Wall Push-up (方形)
        ```
        ...prompt text...
        ```
    Filenames ending in _sq.jpg get aspectRatio "1:1".
    Filenames ending in _ls.jpg get aspectRatio "16:9".
    """
    text = md_path.read_text(encoding="utf-8")
    pattern = re.compile(
        r"###\s+([\w]+\.jpg)[^\n]*\n```\n(.*?)\n```",
        re.DOTALL,
    )
    # Regex to extract exercise type and step number from filename
    name_re = re.compile(r"^([a-zA-Z]+)_(\d+)_")

    entries = []
    for m in pattern.finditer(text):
        filename = m.group(1)
        prompt = " ".join(m.group(2).split())  # collapse whitespace
        aspect = "16:9" if filename.endswith("_ls.jpg") else "1:1"

        nm = name_re.match(filename)
        exercise = nm.group(1) if nm else ""
        step = int(nm.group(2)) if nm else 0

        entries.append({
            "filename": filename,
            "prompt": prompt,
            "aspect": aspect,
            "exercise": exercise,
            "step": step,
        })
    return entries


def filter_entries(
    entries: list[dict],
    exercise_filter: str,
    step_filter: set[int] | None,
) -> list[dict]:
    result = []
    for entry in entries:
        if exercise_filter != "all" and entry["exercise"] != exercise_filter:
            continue
        if step_filter is not None and entry["step"] not in step_filter:
            continue
        result.append(entry)
    return result


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
    args = parse_args()

    if not API_KEY:
        print("ERROR: GEMINI_API_KEY is not set.")
        print("  Run:  export GEMINI_API_KEY=AIza...")
        sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    all_entries = parse_prompts(PROMPTS_FILE)
    if not all_entries:
        print("ERROR: No prompts found in", PROMPTS_FILE)
        sys.exit(1)

    step_filter = parse_steps(args.steps)
    entries = filter_entries(all_entries, args.exercise, step_filter)

    if not entries:
        print("No entries match the given --exercise / --steps filter.")
        sys.exit(0)

    # Summary of what will be generated
    ex_label = args.exercise if args.exercise != "all" else "all exercises"
    step_label = args.steps if args.steps else "all steps"
    print(f"Exercise : {ex_label}")
    print(f"Steps    : {step_label}")
    print(f"Overwrite: {'yes' if args.overwrite else 'no'}")
    print(f"Matched  : {len(entries)} image(s)\n")

    success = 0
    failed = []

    for i, entry in enumerate(entries, 1):
        filename = entry["filename"]
        aspect   = entry["aspect"]
        out_path = OUTPUT_DIR / filename

        if out_path.exists() and not args.overwrite:
            print(f"[{i:03d}/{len(entries)}] SKIP  {filename}  (already exists)")
            success += 1
            continue

        if out_path.exists() and args.overwrite:
            out_path.unlink()

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
