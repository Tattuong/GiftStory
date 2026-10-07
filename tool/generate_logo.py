#!/usr/bin/env python3
"""A wine journal with a ribbon bookmark for the GiftStory launcher."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SIZE = 1024
CREAM = (251, 246, 239, 255)
WINE = (122, 35, 70, 255)
RIBBON = (244, 198, 214, 255)


def _mark(canvas: Image.Image) -> None:
    draw = ImageDraw.Draw(canvas)
    left, top, right, bottom = 300, 236, 724, 748
    draw.rounded_rectangle((left, top, right, bottom), radius=84, fill=WINE)
    draw.polygon(
        [(470, top), (554, top), (554, 860), (512, 792), (470, 860)],
        fill=RIBBON,
    )


def main() -> None:
    assets = ROOT / "assets"
    assets.mkdir(exist_ok=True)

    logo = Image.new("RGBA", (SIZE, SIZE), CREAM)
    _mark(logo)
    logo.convert("RGB").save(assets / "logo.png", optimize=True)

    splash = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _mark(splash)
    splash_path = ROOT / "android/app/src/main/res/drawable-nodpi/splash_icon.png"
    splash_path.parent.mkdir(parents=True, exist_ok=True)
    splash.save(splash_path, optimize=True)
    print(f"wrote {assets / 'logo.png'}")


if __name__ == "__main__":
    main()
