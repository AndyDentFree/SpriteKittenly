# akshunned Research into particleAction

Testing the assertion that the [particleAction][pa] has been broken since iOS8 or 9.

## Problems Claimed
### Early Touchgram testing
I've lost details on what made me suspect they didn't work. I just have an old note from around 2020 that says (re the [SO below][so1]) _seems confirmed by my testing, had reputation for buggy behaviour & warnings about using them_

### StackOverflow -  SKEmitterNode particleAction not working iOS9 Beta
This [StackOverflow question][so1] asserts that they stopped working in an iOS9 beta.

Objective-C sample:
```
// create the particle movement action
SKAction *move = [SKAction moveByX:100 y:100 duration:5]; // also, I've tested several other SKActions, such as scaleBy, fade, rotate, to no effect here        

// create a target node and add to the SKScene
SKNode *targetNode = [SKNode node];
targetNode.position = origin;
[mySKSceneNode addChild:targetNode];

// add an emitter node that has a target and an SKAction
SKEmitterNode *flameTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"FlameAttack" ofType:@"sks"]];
flameTrail.position = origin;
flameTrail.particleAction = move; // TODO iOS9 compatibility issues!
flameTrail.targetNode = targetNode;
[mySKSceneNode addChild:flameTrail];
```

but other responses further down suggest that setting both the `particleZPosition` and `zPosition` on the emitter **should fix this!**

### StackOverflow - 
[This related SO][so3] has similar complaint and I commented on it that my testing seemed to confirm.

### Open Radar on not rendering
This [report][rad1] _When using a SKEmitterNode in iOS 9.0, particles are not being emitted (or rendered to the screen) when the emitter's particleAction is a SKAction that uses the method 'animateWithTextures: timePerFrame'._ 

## Misled by YouTubes
This [YouTube tutorial - "Using SpriteKit Particle Emitters to Make Shapes Explode | Learning Xcode GameDev"][yt1] shows up when searching for `particleAction` but I don't think it actually does one.



[so1]: https://stackoverflow.com/questions/31714076/skemitternode-particleaction-not-working-ios9-beta
[so2]: https://stackoverflow.com/questions/69736353/setting-skemitternodes-targetnode-causes-strange-zposition-behavior
[so3]: https://stackoverflow.com/questions/39489179/spritekit-skemitternode-particleaction-not-working-in-xcode-8-ios-10
[pa]: https://developer.apple.com/documentation/spritekit/skemitternode/1397970-particleaction
[yt1]: https://www.youtube.com/watch?v=zyly5HhA6ao
[rad1]: https://openradar.appspot.com/22626752

