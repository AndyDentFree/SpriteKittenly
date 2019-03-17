# SKScribbles
Exploring different ways to handle free-form drawing in SpriteKit with Swift

* `ShapeScribbling.playground` uses `SKShapeNode` to track a continuously updated drawing. Note that it ran into an interesting _behaviour_ in XCode 9.3 where appending nodes to an array caused a dramatic drop in interactive performance **in the playground only**.
* `ShapeScribble` is an iOS and macOS app using the logic from `ShapeScribbling.playground` to prove that it performs fine when compiled into apps. It compares approaches (segment control at top of screen to pick mode):
    * `GameScene2LineNodes` uses a set of nodes for **each** contiguous vector
        * As you draw, it adds a new `SKShapeNode` containing one short line, for each new point (more than 2.0 in x or y from prev point). That is a massive number of tiny _temp nodes_. The points are recorded in an array
        * On touch-up: 
            * The temp nodes are all removed.
            * A new node is created from the array of points, using the `SkShapeNode(splinePoints:, count:)` init which allows SpriteKit a chance to optimise line paths and generate a smoother line. Note that for many individual strokes, we still have one node per contiguous stroke.
    * `GameScenePathRebuilding` has **one big SKShapeNode**. 
        * As you draw, it builds up an array of points,adding a new point every time it is more than 2.0 in x or y from prev point.
        * On touch-up adds lines to the `CGMutablePath` of the single `SKShapeNode`. The path is re-assigned on each touch-up, causing the shapenode to regenerate its content. As we don't re-create the path, it ends up with multiple separate segments for each contiguous set of strokes.
    
    
## Effects of different approaches

Scribbling with my awkward handwriting and an Adonit Jot Pro styles on an iPhone provides testing of a mix of tight turns and tiny strokes.


### Line2Nodes approach

<img alt="Sample shot of Line2Nodes" src="./img/2LineNodes_sample.png" width=400/> 
<img alt="Sample shot of PathRebuild" src="./img/PathRebuild_sample.png" width=400 />

With the screenshots blown up you can see the _glow_ effect applied on Lines2Node. 

To my eye, this is PathRebuild is a little bit more jerky as each set of points is connected with a straight line, so when moving fast they have no smoothing. This is most noticeable on the capital P of _Pro_