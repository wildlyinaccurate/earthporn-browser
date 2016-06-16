# EarthPorn Browser

I wanted a simple, gallery-esque interface for browsing through images from [r/earthporn](https://www.reddit.com/r/earthporn). This is what I've come up with.

Navigating through posts can be done in a few different ways:

 * Tapping or clicking the left and right sides of the page
 * Using the left and right arrows on a keyboard
 * Swiping left or right (still in progress)

You can build this with [Elm](http://elm-lang.org/install) (see instructions below) or view the [live demo](https://wildlyinaccurate.com/earthporn-browser/).

## Building Locally

Clone this repository and build `Main.elm`.

```
$ git clone https://github.com/wildlyinaccurate/earthporn-browser.git
$ cd earthporn-browser
$ elm make Main.elm --output earthporn-browser.js
```

Then open `index.html`.

# LICENSE

The MIT License (MIT)

Copyright (c) 2016 Joseph Wynn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
