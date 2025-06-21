# VidExies

Video export of views with SpriteKit within a SwiftUI App, particularly for `SKEmitterNode`.

For a detailed comparison on different approaches on using SpriteKit in SwiftUI, see `../SkinSuit/README.md`

For explanation of the emitters used to get a nice complex display to export, see `../ResizingRemit/README.md`

This sample was created when the [Purrticles app][p1] video export was being added, to explore different approaches.

## ReplayKit whole screen capture
[ReplayKit][a3] is the simple approach to recording your whole screen.

It even supports Mac - see [Recording and Streaming Your macOS App][a4], although with some horrible sizing woes.

Note that with ReplayKit you are [prompted for permission to record][a8]:

>Before recording starts, ReplayKit presents a user consent alert requesting that the user acknowledge their intent to record the screen, the microphone and the front-facing camera. This alert is presented once per app process and it’s presented again if the app is left in the background for longer than 8 minutes.


**WARNING: you must test ReplayKit on real devices. The iOS simulators won't prompt and won't record.**


### Simple whole screen capture
The pair of [startRecording][a1] and [stopRecording][a2] are used.

When complete, you need to display a [RPPreviewViewController][a5] which inherits from either `NSViewController`
or `UIViewController`. So we use a similar `AgnosticViewRepresentable` as used for `SKView`, but a bit simpler.

[This StackOverflow question][so1] helped.


## Direct frame capture

Saves a video direct to the Documents folder as a file, without any need to authorise recording.

This first version just saves at the same size as the current playing view, which is paused for the duration.

This is vastly more complicated than using ReplayKit, because it's replacing the role of `SKView`. 

The main components used by `ExportSKView.exportFrameWise` are:
- `FrameCaptureRecorder` which captures each frame of the scene
- a `OffscreenRenderTimer` which manages the timing to update and capture the scene
- an `AVAssetWriter` converts the pixel buffer and writes it to the movie on disk

### Ugly SKView passed around
As quick hack to get this working, the SKView created inside the `SpriteKitContainerWithGen` is passed back to the calling context so that it can be then passed down and manipulated in `exportFrameWise` and `stopRecordingFramewise`. We use a trivial wrapper class `SKViewOwner` for this.



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
[a8]: https://support.apple.com/en-au/guide/security/seca5fc039dd/web

[p1]: https://www.touchgram.com/purrticles
[so1]: https://stackoverflow.com/questions/59842682/replaykit-with-swiftui