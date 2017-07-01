# Moroxite

How much time you spent downloading images from the internet to serve as part
of you wallpaper collection? I bet if you ended up here it isn't as much as you
want. Moroxite is a "wallpaper engine" which will crawl parts of the web for
you to download wallpapers and serve them to your desktop directly.


# Dependencies
The application, when it is ready, will most likely use ```feh``` in order to
show the images. At some point I might want to play around with X, but I will
skip this part for now.

# Architecture
```MoroxiteServer``` will be the daemon running in the background making sure
you have the newest wallpapers from around Reddit, while ```MoroxiteClient```
will make sure that you have enought control over what you want to be on this
precious desktop of yours.
