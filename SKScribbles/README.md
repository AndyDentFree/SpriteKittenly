# SKScribbles
Exploring different ways to handle free-form drawing in SpriteKit with Swift

* `ShapeScribbling.playground` uses `SKShapeNode` to track a continuously updated drawing. Note that it ran into an interesting _behaviour_ in XCode 9.3 where appending nodes to an array caused a dramatic drop in interactive performance.
* `ShapeScribble` is an iOS and macOS app using the logic from `ShapeScribbling.playground` to prove that it performs fine when compiled into apps.