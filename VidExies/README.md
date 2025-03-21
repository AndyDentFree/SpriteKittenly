# VidExies

Video export of views with SpriteKit within a SwiftUI App, particularly for `SKEmitterNode`.

For a detailed comparison on different approaches on using SpriteKit in SwiftUI, see `../SkinSuit/README.md`

For explanation of the emitters used to get a nice complex display to export, see `../ResizingRemit/README.md`

This sample was created when the [Purrticles app][p1] video export was being added, to explore different approaches.

## ReplayKit whole screen capture
[ReplayKit][a3] is the simple approach to recording your whole screen.

It even supports Mac - see [Recording and Streaming Your macOS App][a4].

**WARNING: you must test ReplayKit on real devices. The iOS simulators won't prompt and won't record.**


### Simple whole screen capture
The pair of [startRecording][a1] and [stopRecording][a2] are used.

When complete, you need to display a [RPPreviewViewController][a5] which inherits from either `NSViewController`
or `UIViewController`. So we use a similar `AgnosticViewRepresentable` as used for `SKView`, but a bit simpler.

[This StackOverflow question][so1] helped.


## Wrapping ViewControllers
Unlike most of the samples, as well as wrapping an `SKView` we also need to present ViewControllers so this sample introduces `AgnosticViewControllerRepresentable` which is a _facade_ for [UIViewControllerRepresentable][a6] or [NSViewControllerRepresentable][a7].

### Getting the PreviewController back out
To stop, we eventually have to invoke `RPScreenRecorder.shared().stopRecording` with a closure that receives an instance of `RPPreviewViewController`. That's handled by having the `ExportSKVideo` class both provide the `stopRecording()` function and, in there, provide a closure to save the PreviewController. With the exporter also providing `makePreview()`, it can use the saved PreviewController.

[a1]: https://developer.apple.com/documentation/replaykit/rpscreenrecorder/startrecording(handler:)
[a2]: https://developer.apple.com/documentation/replaykit/rpscreenrecorder/stoprecording(handler:)
[a3]: https://developer.apple.com/documentation/replaykit/
[a4]: https://developer.apple.com/documentation/replaykit/recording-and-streaming-your-macos-app
[a5]: https://developer.apple.com/documentation/replaykit/rppreviewviewcontroller
[a6]: https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable
[a7]: https://developer.apple.com/documentation/swiftui/nsviewcontrollerrepresentable

[p1]: https://www.touchgram.com/purrticles
[so1]: https://stackoverflow.com/questions/59842682/replaykit-with-swiftui