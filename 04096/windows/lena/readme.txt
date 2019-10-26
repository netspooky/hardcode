author: ......................................................... Witek
date: ....................................................... July 2017
type: .................................................. procedural gfx
platform: ..................................................... Windows


technical details:

The image is IFS fractal. The 512x512 image is subdivided into blocks
of sizes between 8x8 and 64x64 pixels (adaptive quadtree subdivision).
Then, each block corresponds to another, arbitrary image region that
is 2x bigger. During mapping a block can be rotated, flipped and it's
colors are transformed (scaled and offseted). This process is performed
for three channels (luma + 2 chroma channels, 4x downsampled).
It took few minutes for a manually-crafted encoder to generate blocks
mapping and hours to select optimal parameters.