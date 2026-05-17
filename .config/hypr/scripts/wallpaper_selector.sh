#!/bin/bash

WALL_DIR="$HOME/.config/hypr/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpaper/wallpaper.rasi"
mkdir -p "$THUMB_DIR"

generate_thumb() {
    local file="$1"
    local name=$(basename "$file")
    local thumb="$THUMB_DIR/${name%.*}.png"

    [[ -f "$thumb" ]] && return

    local ext="${file##*.}"
    ext="${ext,,}"

    case "$ext" in
        mp4|webm|mkv)
            ffmpeg -i "$file" -vframes 1 -q:v 2 \
                -vf "scale=210:210:force_original_aspect_ratio=increase,crop=210:210" \
                "$thumb" -y 2>/dev/null
            ;;
        gif)
            convert "${file}[0]" -resize 210x210^ -gravity Center -extent 210x210 "$thumb" 2>/dev/null
            ;;
        jpg|jpeg|png|webp)
            convert "$file" -resize 210x210^ -gravity Center -extent 210x210 "$thumb" 2>/dev/null
            ;;
    esac
}

while IFS= read -r file; do
    generate_thumb "$file"
done < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \
    -o -iname "*.mp4" -o -iname "*.webm" \) | sort)

ENTRIES=()
while IFS= read -r file; do
    name=$(basename "$file")
    thumb="$THUMB_DIR/${name%.*}.png"
    [[ -f "$thumb" ]] && ENTRIES+=("${name}\0icon\x1f${thumb}")
done < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \
    -o -iname "*.mp4" -o -iname "*.webm" \) | sort)

chosen=$(printf '%b\n' "${ENTRIES[@]}" | rofi \
    -dmenu \
    -p "Wallpaper" \
    -show-icons \
    -theme "$ROFI_THEME")

[[ -z "$chosen" ]] && exit 0

WALL_PATH="$WALL_DIR/$chosen"
[[ -f "$WALL_PATH" ]] && bash "$HOME/.config/hypr/scripts/wallpaper.sh" "$WALL_PATH"
