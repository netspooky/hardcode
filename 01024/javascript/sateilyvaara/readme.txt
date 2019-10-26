/**********************\
***** SÄTEILYVAARA *****
****by Exca/Wide Load***
************************

Run the intro by launching correct .html file based
on your browser. _HD indicates 1080p. Otherwise 720p is used.
Intro loops forever, quit when bored.

Chrome, no touch: out_chrome.html
Chrome, touch input: out_chrome_touch.html
Firefox: out_fox.html
Others: out_generic.html.

Chrome and firefox versions are only 1k. Generic version is a bit larger but works on all platforms.
Other browser versions can be compiled to be <= 1024 bytes, but I ran out of time, so generic will have to do for the ie/opera -users (and for the future versions of browsers).
Intro will most likely be broken in near future as the last 100 bytes were crunched with a very volatile hack.

Plugins might break the browser specific versions as well as browser updates.

Tested with:
	Chrome: 44.0.2403.107 (Official Build) m (32-bit)
	Firefox: 39.0