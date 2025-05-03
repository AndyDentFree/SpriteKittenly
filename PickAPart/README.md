# PickAPart

This sample was created when the [Purrticles app][p1] was having problems with grey views instead of emitters being drawn, in both the picker and preview. See [GitHub issue 23][p2].

It replicates some of the visual behaviour of the document browser opening either a known document or grid of cells for picking the initial template. If this doesn't provide a replicable case, next step may be to do a true document browser in case there's something about its overall navigation view structure that changed in 18.4.

## Emitters on scenes
For the purpose of this test we have just one emitter per scene.

Simple indexing is used to provide an indication of how to update the emitter. The scene maker just retains **one** emitter to adjust, of the 16 variations it can make. The index is used by `EmitterSceneMaker` 

## A picker or content main view
The `PaPView` shows either
- `TemplatePickerView` grid with many emitters playing
- `PreviewView` which shows one emitter taking up most of the screen

## Resizable Views
The views used for the template picker need to be resizeable due to the layout loop that can occur for the grid.

The `SpriteKitContainerWithGen` is used in two distinct views - `TemplateView` and `PreviewView` at very different sizes.


[p1]: https://www.touchgram.com/purrticles
[p2]: https://github.com/Touchgram/purrticles/issues/23
