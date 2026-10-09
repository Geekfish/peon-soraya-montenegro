# Soraya Montenegro (Greek dub)

[peon-ping](https://peonping.com) sound pack with Soraya Montenegro the villain of the 1995 Mexican telenovela *María la del Barrio*, in the Greek dub (*Μαρία της Γειτονιάς*). Μαρία Πλακίδη is the Greek voice.

Clips were picked by popularity: YouTube view counts and the most-liked comments on the Greek clips.

## Install

```bash
ln -s "$PWD" ~/.claude/hooks/peon-ping/packs/soraya_montenegro_gr
```

## Files

- `sources.tsv`: YouTube ID, start and end time in seconds, and clip name.
- `categories.tsv`: peon-ping category, clip name and label. A clip can be in more than one category.
- `build.sh`: regenerates `openpeon.json`. With `--cut`, it also downloads the sources and cuts the clips again.
- `vad.py`: prints the speech regions in a time window of a voice track. It helps to find cut points. Whisper often makes up words on short shouts, so its timestamps are not reliable there.

The dub has music under the speech. `build.sh --cut` uses [Demucs](https://github.com/adefossez/demucs) to keep only the voice before cutting.

## License

CC-BY-NC-4.0 covers the selection, cuts, manifest and scripts. The audio belongs to its rights holders.

The icon is the [Soraya Montenegro image from Wikipedia](https://en.wikipedia.org/wiki/File:Soraya_Montenegro.jpg), cropped to 256×256. It is a non-free still from the show.
