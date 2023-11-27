# scrolling_subtitles

Releases: https://github.com/tejesh-kaliki/scrolling_subtitles/releases

## Usage:
### Subtitle Specification:
This app currently only supports `vtt` for the subtitle file. Follow these specifications for the content of the subtitle line:
#### 1. Adding character name:
```name: line```

#### 2. More than 1 character:
```name + name + name: line```
 
#### 3. Character speaking in background:
```name(background): line```

#### 4. Italic text: (Enclose the required text in *s)
```name: *This is italic line.*```

#### Subtitle Example:
- For an example on how the vtt file should be specified, check [this file](examples/bookworm-CD5-subs.vtt).

### Keyboard Controls:
```
space - play/pause
Right Arrow - forward 10s
Left Arrow - rewind 10s
f - toggle fit window to content
c - load colors
```

### Colors:
- By default, only colors for a few characters from `Ascendance of a Bookworm` are available. You will have to select colors manually for all the characters.
- Colors file uses a json format. You can just click `save to file` in the colors file to create a json for the current selected colors.
- In case you want to add colors manually, you check [this file](examples/colors.json) for the json format.

### Image Specifications:
- The recommended image resolution is `1125 x 992`. Larger or smaller images can be used by adjusting the text size accordingly.
- But make sure the ratio is similar, because number of subtitles shown at once is fixed for now (8).

### Audio Specifications:
- Supports most of the video and audio formats like `mp4`, `mp3`, `mkv`, `aac`, etc.