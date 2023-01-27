# SkinSuit

Testing how to embed SpriteKit within a SwiftUI App.

The _simple way_ is to use [SpriteView][SV] as shown in [Paul Hudson's tutorial][HWS].

However, that has two limitations:

1. It requires a prebuilt Scene which will be resized to match later, which is counter to the way [touchgram][tg] builds its scene.
2. The `SpriteView` lacks any way for SpriteKit to change scenes other than via recreation.

## Bugs in SpriteView behaviour
The most obvious and one I didn't find a workaround for is that the transition parameter is completely ignored when you init a [SpriteView with transition][SVi].

The subtle second bug occurs when you reuse the scene - after toggling a couple of times a blank gray view appears. Repeated tapping on the toggle button _sometimes_ shows the correct image. This is regardless of specifying the transition so is unlikely to be the [retention bug previously observed][sb].

![Screen recording showing after a few button taps that a grey screen is shown](img/ReusingSKScenesWithSpriteViewProblem.gif "ReusingSKScenesWithSpriteViewProblem.gif")

Both of these are regarded as intractable - will leave this as is to demonstrate this behaviour.

[HWS]: https://www.hackingwithswift.com/quick-start/swiftui/how-to-integrate-spritekit-using-spriteview
[SV]: https://developer.apple.com/documentation/spritekit/spriteview
[SVi]: https://developer.apple.com/documentation/spritekit/spriteview/3592999-init
[tg]: https://www.touchgram.com/
[sb]: https://medium.com/touchgram/oops-hitting-a-5yo-apple-bug-17d2703519f4
