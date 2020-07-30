# Noven

## Example stream commands

Stream a v4l device w/ native h264 encoding

```bash
gst-launch-1.0 -v v4l2src ! video/x-h264, stream-format=byte-stream, alignment=au, width=1920, height=1080, pixel-aspect-ratio=1/1, framerate=30/1 ! rtph264pay pt=96 ! udpsink host=127.0.0.1 port=5000
```


```bash
gst-launch-1.0 -v v4l2src ! video/x-raw ! x264enc ! rtph264pay pt=96 ! udpsink host=127.0.0.1 port=5000
```
