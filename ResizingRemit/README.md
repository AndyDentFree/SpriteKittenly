# ResizingRemit

Resizing views with SpriteKit within a SwiftUI App, particularly for `SKEmitterNode`.

For a detailed comparison on different approaches on using SpriteKit in SwiftUI, see `../SkinSuit/README.md`

This sample was created when the [Purrticles app][p1] full-size preview was having problems with emitters that were not centred.

It acts as a simpler case for debugging, especially should I have decided that some weird behaviour is actually an Apple bug (not that anyone really expects them to fix things in SpriteKit at this stage). It also avoids reliance on any of the Touchgram infrastructure, even the subset used in Purrticles.

## Example

### App before expanding

![<# Phone screenshot showing multiple particle emitters taking up about half the screen #>](img/RR%20Start%20-%20iPhone%2016%20Pro%20Max%20-%202024-12-05%2050pc.png "RR Start - iPhone 16 Pro Max - 2024-12-05 50pc.png")

### App after expanding - emitters have all been moved
Even centred emitters need moving depending on how they have been initially positioned.

![<# Phone screenshot showing multiple particle emitters taking up most of the screen #>](img/RR%20Expanded%20-%20iPhone%2016%20Pro%20Max%20-%202024-12-05%2050pc.png "RR Expanded - iPhone 16 Pro Max - 2024-12-05 50pc.png")



## Detecting size changes
Typical code managing `SKView` relies on detecting things in `UIViewRepresentable.updateUIView`, as shown in our cross-platform `AgnosticViewRepresentable`.

However, for the specific case of the `SKView` being resized by SwiftUI's layout changing, that function **doesn't get called with the new size.**

The most efficient and least-intrusive solution is subclassing SKView to handle `layoutSubviews`:

```
// helper class so can invoke a lambda onLayout, typically when SKView has been resized
class LayoutSensingSKView: SKView {
    
    @MainActor
    var onLayout: ((SKView) -> Void)!
    
    #if os(iOS)
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
    #elseif os(macOS)
    override func layout() {
        super.layout()
        onLayout?(self)
    }
    #endif
}
```

### sizeThatFits ignored
Note that this is called **many** times with a variety of different sizes, often with one dimension being zero. The `AgnosticViewRepresentable` code to use `sizeThatFits` was left in, commented out, if you want to test it further.

### Alternative with GeometryReader
There's an alternative using a `GeometryReader` documented with a snippet in [issue 4][sk4].

I just didn't have time after getting the `onLayout` approach going, to integrate it in here.

## Designing and Creating Emitters
Three emitters are created in code. These were designed in Purrticles using the code export it provides, which only specifies values for the overrides of default SpriteKit parameters. So, compared to other SKEmitter creation in code, they may seem shorter.

Note that the following creation functions have literal values for position, instead of the frame-relative versions used in the app.

```
// Confetti Rain, from top-down
import SpriteKit

func createEmitter() -> SKEmitterNode {
    let em = SKEmitterNode()
    em.position = CGPoint(x: 220, y: 216)
    em.particleBirthRate = 150
    em.particleLifetime = 8
    em.emissionAngle = 4.7124 // radians (270º)
    em.particleSpeed = 80
    em.particleSpeedRange = 150
    em.yAcceleration = -150
    em.particleColor = SKColor(red: 1.0000, green: 1.0000, blue: 1.0000, alpha: 1.0000)  // #ffffffff
    em.particleAlpha = 0.6000
    em.particlePositionRange = CGVector(dx: 400, dy: 2)
    em.particleSize = CGSize(width: 8, height: 16)
    em.particleColorRedRange = 2
    em.particleColorGreenRange = 2
    em.particleColorBlueRange = 2
    em.particleRotationRange = 2.0944 // radians (120º)
    return em
}



// minimal, centred
import SpriteKit

func createEmitter() -> SKEmitterNode {
    let em = SKEmitterNode()
    em.particleSize = CGSize(width: 8, height: 8) // default size if no texture
    em.particleBirthRate = 10
    em.particleLifetime = 2
    em.emissionAngleRange = 6.2832 // radians (360º)
    em.particleSpeed = 80
    em.particleColor = SKColor(red: 0.9569, green: 0.1137, blue: 0.9333, alpha: 1.0000)  // #fff41dee
    return em
}



// Smoke from bottom up
import SpriteKit

func createEmitter() -> SKEmitterNode {
    let em = SKEmitterNode()
    em.particleTexture = SKTexture(imageNamed: "spark")
    em.position = CGPoint(x: 204, y: 39)
    em.particleBirthRate = 40
    em.particleLifetime = 10
    em.emissionAngle = 1.5708 // radians (90º)
    em.emissionAngleRange = 0.3491 // radians (20º)
    em.particleSpeed = 40
    em.particleSpeedRange = 40
    em.yAcceleration = 10
    em.particleAlpha = 0.4000
    em.particleAlphaRange = 0.3000
    em.particleAlphaSpeed = -0.1500
    em.particleScale = 0.5000
    em.particleScaleSpeed = 0.5000
    em.particleRotationRange = 6.2832 // radians (360º)
    em.particleRotationSpeed = 3.0020 // radians (172º)
    em.particleColor = SKColor(red: 0.1098, green: 0.1098, blue: 0.1059, alpha: 1.0000)    // #ff1c1c1b
    em.particleColorBlendFactor = 1
    em.particlePositionRange = CGVector(dx: 40, dy: 5)
    return em
}
```


[p1]: https://www.touchgram.com/purrticles
[sk4]: https://github.com/AndyDentFree/SpriteKittenly/issues/4