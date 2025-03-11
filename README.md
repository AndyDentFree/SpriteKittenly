# SpriteKittenly
Exploring cute and sometimes scratchy corners of SpriteKit with Swift.

Main motivation finding ways to do things for touch feedback and rendering in [Touchgram][tg] which was initially ported from C++ and the Cocos2D-X game framework. Touchgram lets you compose multi-page interactive messages within Apple iMessage.

The SwiftUI samples mostly built as part of the [Purrticles][p1] Particle Editor app which is a companion to Touchgram but also a developer and designer tool in its own right.

See specific README in each project directory


## Feedback and Graphic Effects
* [SKScribbles](./SKScribbles/) multiple approaches tried with sample images to show smoothness of different drawings, also see the closely-related...
* [streakios](./streakios/) which wraps someone else's work and draws a decaying streak, like I was using in Cocos2D-X
* [ThrobsAndBobs](./ThrobsAndBobs/) different ways to have shapes that _throb_ and animation along paths
* [FramesAndBackgrounds](./FramesAndBackgrounds/) Exploring tiling backgrounds and using shaders to frame an image.
* [SKShaderToy](./SKShaderToy/) Little testbed with text entry to edit a GLSL shader & see it recompiled and in action.


## Text oriented
* [StyledTextOverSK](./StyledTextOverSK/) long discussion of how to combine SpriteKit with styled text. I went with an SKLabelNode using NSAttributedString in [Touchgram](https://www.touchgram.com/) because of the  performance issues this sample shows.
* [FontThraSKing](./FontThraSKing/) simple use of different fonts, picking them and displaying in SpriteKit, mostly created to get understanding of a crash

## SwiftUI
* [SkinSuit](./SkinSuit/) Embedding SpriteKit within SwiftUI, exploring two different approaches.
* [ResizingRemit](./ResizingRemit/) Using within SwiftUI responding to a resized area by adjusting the scene.


## General
* LottieSprite - unfinished exploration, don't bother
* [ToP3orNotToP3](./ToP3orNotToP3) Testing how P3 color space affects simple rendering in SpriteKit.


[tg]: https://www.touchgram.com
[p1]: https://www.touchgram.com/purrticles
