# SkinSuit

Testing how to embed SpriteKit within a SwiftUI App.

The _simple way_ is to use [SpriteView][SV] as shown in [Paul Hudson's tutorial][HWS].

However, that has two limitations:

1. It requires a prebuilt Scene which will be resized to match later, which is counter to the way [touchgram][tg] builds its scene.
2. ~~The `SpriteView` lacks any way for SpriteKit to change scenes other than via recreation.~~

The limitation I thought I had found, which is echoed in a few questions has an easy workaround, thanks to [this stackoverflow question][so1] showing that you can simply:

1. Retain a property to the `SKScene` you pass into `SpriteView`
2. Use [SKScene.view][sk1] to get the backing `SKVieww` created inside `SpriteView`
3. Call [presentScene(SKScene)][sk2] or [presentScene(SKScene, transition: SKTransition)][sk3] to show the next scene in the game.

This avoids the [typical hacks][sk4] forcing rebuild of the SwiftUI view structure
 
## Bugs in SpriteView behaviour
With the changes in 2025-04-01, the sample has now become robust. Previous gotchas seem to have been accidentally reusing `SKScene` objects - now we're using generators.

However, there's still **a long-standing Apple bug in SpriteKit on iOS** that can be seen in this demo. As I [wrote in an article][sb], when you have scene transitions, you cannot have any other active `SKView` retained.

The current version of SkinSuit demonstrates that this bug occurs regardless of using the SpriteView or SKView hosted approaches. It lets you toggle which of the two approaches is loaded first in the tab view. That one has working transitions. The other will appear unable to change scenes, if transitions are turned on. It is a rendering problem - the scene actually does change but is not rendered.


## SKView inside SwiftUI
The escape hatch of [UIViewRepresentable][rep] is used by `SKViewApproach`.

### Cleanup logic
Using different tabs as shown here is a bit more problematic for cleanup - it shouldn't be a problem but note [dismantleUIView][dv] is **not** invoked just changing tabs - it would only be when going to another screen or if the entire content is dropped from the view. 

The sample was changed so in `ContentView` now we can use the **Hide SpriteKit Demos** button to ensure destruction happens.

```
    if isShowingSpriteKit {
        TabView {
            SKViewApproach...

```

Going to the SpriteKit view and back out again with **Hide SpriteKit Demos** will show the following in the debug console in Xcode.

```
InitLogger init - SKContainer
dismantleView invoked in SKViewApproach
InitLogger deinit - SKContainer
```


[HWS]: https://www.hackingwithswift.com/quick-start/swiftui/how-to-integrate-spritekit-using-spriteview
[SV]: https://developer.apple.com/documentation/spritekit/spriteview
[SVi]: https://developer.apple.com/documentation/spritekit/spriteview/3592999-init
[tg]: https://www.touchgram.com/
[sb]: https://medium.com/touchgram/oops-hitting-a-5yo-apple-bug-17d2703519f4
[so1]: https://stackoverflow.com/questions/77253995/how-to-transitions-between-scenes-using-spriteview-in-swiftui
[sk1]: https://developer.apple.com/documentation/spritekit/skscene/view
[sk2]: https://developer.apple.com/documentation/spritekit/skview/presentscene(_:)
[sk3]: https://developer.apple.com/documentation/spritekit/skview/presentscene(_:transition:)
[sk4]: https://stackoverflow.com/questions/68784060/spritekit-and-swiftui-change-scene-a-better-way
[rep]: https://developer.apple.com/documentation/swiftui/uiviewrepresentable
[dv]: https://developer.apple.com/documentation/swiftui/uiviewrepresentable/dismantleuiview(_:coordinator:)-5lee7
