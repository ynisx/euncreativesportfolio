#!/bin/bash
# Re-convert renamed source videos to web H.264 + thumbnails, grouped by category.
set -u
FF=/tmp/ffmpeg
SRC="/Users/eunicedeguzman/Downloads/eun_creatives_video_portfolio/videos"
OUT="$SRC/web"
THB="$SRC/thumbs"
mkdir -p "$OUT" "$THB"

# Clear old clips/thumbs (they referenced the previous filenames).
rm -f "$OUT"/*.mp4 "$THB"/*.jpg

# source|output-base
LIST=(
"ugcvideo1.mp4|ugc-1"
"ugcvideo2.mp4|ugc-2"
"ugcvideo3.mp4|ugc-3"
"ugcvideo4.mp4|ugc-4"
"ugcvideo5.mp4|ugc-5"
"shortvideo1.mp4|short-1"
"shortvideo2.mp4|short-2"
"shortvideolifestyle1.mp4|short-3"
"shortvideolifestyle2.mp4|short-4"
"shortvideolifestyle3.mp4|short-5"
"Viral_talking_heads1.mp4|heads-1"
"Viral_talking_heads2.mp4|heads-2"
"Viral_talking_heads3.mp4|heads-3"
"aishortvideo1.mp4|ai-1"
)

for entry in "${LIST[@]}"; do
  src="$SRC/${entry%%|*}"
  base="${entry##*|}"
  out="$OUT/$base.mp4"
  thumb="$THB/$base.jpg"

  if [ ! -f "$src" ]; then echo "SKIP (missing): $src"; continue; fi
  echo "==> $base  <-  ${entry%%|*}"

  "$FF" -y -i "$src" \
    -vf "scale=1280:1280:force_original_aspect_ratio=decrease" \
    -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 26 -preset fast \
    -movflags +faststart -c:a aac -b:a 128k -ac 2 \
    "$out" </dev/null >/dev/null 2>&1

  "$FF" -y -ss 1 -i "$out" -frames:v 1 -vf "scale=480:-2" "$thumb" </dev/null >/dev/null 2>&1

  sz=$(du -h "$out" 2>/dev/null | cut -f1)
  echo "    done -> $base.mp4 ($sz)"
done

echo "ALL DONE"
ls -1 "$OUT"
ls -1 "$THB"
