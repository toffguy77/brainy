#!/usr/bin/env python3
"""
Compose App Store screenshots with gradient header and caption text.

Reads raw screenshots from screenshots/raw/{device}/{locale}/{name}.png
Outputs final images to screenshots/final/{device}/{locale}/{name}.png
"""
import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

# --- Configuration ---

SCRIPT_DIR = Path(__file__).parent
PROJECT_DIR = SCRIPT_DIR.parent
RAW_DIR = PROJECT_DIR / "screenshots" / "raw"
FINAL_DIR = PROJECT_DIR / "screenshots" / "final"
FONT_PATH = PROJECT_DIR / "assets" / "fonts" / "Nunito-Bold.ttf"

DEVICES = {
    "6.7": (1290, 2796),
    "6.5": (1242, 2688),
    "ipad-13": (2048, 2732),
}

SCREENS = ["home", "game", "result", "characters", "progress", "parent"]

CAPTIONS = {
    "ru": {
        "home": "Тренируй внимание каждый день",
        "game": "Таблицы Шульте от 3×3 до 9×9",
        "result": "Ставь рекорды и получай звёзды",
        "characters": "Собирай персонажей",
        "progress": "Следи за прогрессом",
        "parent": "Контроль для родителей",
    },
    "en": {
        "home": "Train your focus daily",
        "game": "Schulte tables from 3×3 to 9×9",
        "result": "Set records and earn stars",
        "characters": "Collect characters",
        "progress": "Track your progress",
        "parent": "Parent controls",
    },
}

# Colors
COLOR_PRIMARY = (108, 92, 231)     # #6C5CE7
COLOR_SECONDARY = (0, 206, 201)    # #00CEC9
COLOR_BG = (13, 13, 26)           # #0D0D1A
COLOR_WHITE = (255, 255, 255)

HEADER_RATIO = 0.15  # Top 15% for caption


def create_gradient(width: int, height: int) -> Image.Image:
    """Create a horizontal gradient from primary to secondary color."""
    # Render a 1-pixel-high line then stretch vertically (fast)
    line = Image.new("RGB", (width, 1))
    for x in range(width):
        ratio = x / max(width - 1, 1)
        r = int(COLOR_PRIMARY[0] + (COLOR_SECONDARY[0] - COLOR_PRIMARY[0]) * ratio)
        g = int(COLOR_PRIMARY[1] + (COLOR_SECONDARY[1] - COLOR_PRIMARY[1]) * ratio)
        b = int(COLOR_PRIMARY[2] + (COLOR_SECONDARY[2] - COLOR_PRIMARY[2]) * ratio)
        line.putpixel((x, 0), (r, g, b))
    return line.resize((width, height), Image.NEAREST)


def find_font_size(draw: ImageDraw.ImageDraw, text: str, font_path: str,
                   max_width: int, max_height: int) -> ImageFont.FreeTypeFont:
    """Find the largest font size that fits within max_width and max_height."""
    size = 80
    while size > 20:
        font = ImageFont.truetype(str(font_path), size)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]
        if text_w <= max_width and text_h <= max_height:
            return font
        size -= 2
    return ImageFont.truetype(str(font_path), 20)


def compose_screenshot(raw_path: Path, output_path: Path,
                       caption: str, target_w: int, target_h: int) -> None:
    """Compose a single final screenshot."""
    header_h = int(target_h * HEADER_RATIO)
    body_h = target_h - header_h

    # Create final image
    final = Image.new("RGB", (target_w, target_h), COLOR_BG)

    # Draw gradient header
    gradient = create_gradient(target_w, header_h)
    final.paste(gradient, (0, 0))

    # Draw caption text
    draw = ImageDraw.Draw(final)
    padding = int(target_w * 0.08)
    font = find_font_size(draw, caption, FONT_PATH,
                          target_w - padding * 2, header_h - padding)
    bbox = draw.textbbox((0, 0), caption, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    text_x = (target_w - text_w) // 2
    text_y = (header_h - text_h) // 2 - bbox[1]  # correct for font top bearing
    draw.text((text_x, text_y), caption, fill=COLOR_WHITE, font=font)

    # Scale and paste raw screenshot
    raw = Image.open(raw_path).convert("RGB")  # drop alpha channel if present
    raw_ratio = raw.width / raw.height
    body_ratio = target_w / body_h

    if raw_ratio > body_ratio:
        # Wider than target: fit to width, crop height
        new_w = target_w
        new_h = int(target_w / raw_ratio)
    else:
        # Taller than target: fit to height, center horizontally
        new_h = body_h
        new_w = int(body_h * raw_ratio)

    raw_resized = raw.resize((new_w, min(new_h, body_h)), Image.LANCZOS)
    paste_x = max(0, (target_w - raw_resized.width) // 2)
    paste_y = header_h + max(0, (body_h - raw_resized.height) // 2)
    final.paste(raw_resized, (paste_x, paste_y))

    # Save
    output_path.parent.mkdir(parents=True, exist_ok=True)
    final.save(output_path, "PNG")
    print(f"  ✓ {output_path.relative_to(PROJECT_DIR)}")


def main():
    if not FONT_PATH.exists():
        print(f"ERROR: Font not found at {FONT_PATH}")
        return

    if not RAW_DIR.exists():
        print(f"ERROR: Raw screenshots directory not found at {RAW_DIR}")
        print("Run the Flutter integration test first.")
        return

    count = 0
    for device, (target_w, target_h) in DEVICES.items():
        for locale in ["ru", "en"]:
            raw_locale_dir = RAW_DIR / device / locale
            if not raw_locale_dir.exists():
                print(f"  Skipping {device}/{locale} — no raw screenshots")
                continue

            print(f"\n{device} / {locale}:")
            for screen in SCREENS:
                raw_path = raw_locale_dir / f"{screen}.png"
                if not raw_path.exists():
                    print(f"  ✗ Missing: {raw_path.relative_to(PROJECT_DIR)}")
                    continue

                caption = CAPTIONS[locale][screen]
                output_path = FINAL_DIR / device / locale / f"{screen}.png"
                compose_screenshot(raw_path, output_path, caption,
                                   target_w, target_h)
                count += 1

    print(f"\nDone! {count} screenshots composed.")


if __name__ == "__main__":
    main()
