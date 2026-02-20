# Converting SVG to TGA for WoW Addons

## Requirements

- **librsvg** (SVG renderer): `brew install librsvg`
- **ImageMagick 7+**: `brew install imagemagick`

## Command

Two-step process — rsvg-convert handles SVG rendering properly, then ImageMagick converts to TGA:

```bash
rsvg-convert -w 512 -h 512 Input.svg -o Input.png
magick Input.png -type TrueColorAlpha -compress None Input.tga
```

## Why Two Steps?

ImageMagick's built-in SVG renderer (MSVG) doesn't anti-alias strokes properly. `rsvg-convert` produces clean anti-aliased output.

## TGA Requirements for WoW

- **Dimensions**: Power-of-2 (256, 512, 1024). Use 512x512 to match existing circle assets.
- **Color**: 32-bit RGBA (TrueColorAlpha) — required for transparency
- **Compression**: None (uncompressed)

## Batch Convert

```bash
for svg in *.svg; do
    name="${svg%.svg}"
    rsvg-convert -w 512 -h 512 "$svg" -o "${name}.png"
    magick "${name}.png" -type TrueColorAlpha -compress None "${name}.tga"
    rm "${name}.png"
done
```
