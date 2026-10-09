#!/usr/bin/env bash
# Rebuild the clips and the manifest.
#   ./build.sh            regenerate openpeon.json from sounds/ and categories.tsv
#   ./build.sh --cut      also download, separate and cut every clip in sources.tsv first
# Needs yt-dlp, ffmpeg and jq. --cut also needs demucs (pip install git+https://github.com/adefossez/demucs).
set -euo pipefail
cd "$(dirname "$0")"
WORK=${WORK:-.work}

if [[ ${1:-} == --cut ]]; then
  mkdir -p "$WORK/src" sounds
  for id in $(cut -f1 sources.tsv | sort -u); do
    [[ -f $WORK/src/$id.wav ]] || yt-dlp -q -x --audio-format wav -o "$WORK/src/%(id)s.%(ext)s" "https://youtu.be/$id"
    # The dub has music under the speech. Demucs keeps only the voice.
    [[ -f $WORK/sep/htdemucs_ft/$id/vocals.wav ]] || demucs -n htdemucs_ft --two-stems=vocals -o "$WORK/sep" "$WORK/src/$id.wav"
  done
  while IFS=$'\t' read -r id start end name; do
    ffmpeg -nostdin -loglevel error -y -ss "$start" -to "$end" -i "$WORK/sep/htdemucs_ft/$id/vocals.wav" -ac 1 \
      -af "afade=t=in:d=0.03,areverse,afade=t=in:d=0.03,areverse,loudnorm=I=-16:TP=-1.5" \
      -ar 44100 -b:a 128k "sounds/$name.mp3"
  done < sources.tsv
fi

while IFS=$'\t' read -r category name label; do
  jq -nc --arg c "$category" --arg f "sounds/$name.mp3" --arg l "$label" \
    --arg h "$(shasum -a 256 "sounds/$name.mp3" | cut -d' ' -f1)" '{c:$c, s:{file:$f, label:$l, sha256:$h}}'
done < categories.tsv | jq -s --slurpfile old openpeon.json \
  '$old[0] + {categories: (group_by(.c) | map({key: .[0].c, value: {sounds: map(.s)}}) | from_entries)}' > openpeon.json.new
mv openpeon.json.new openpeon.json
