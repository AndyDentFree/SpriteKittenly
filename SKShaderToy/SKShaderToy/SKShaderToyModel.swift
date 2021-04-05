//
//  SKShaderToyModel.swift
//  SKShaderToy
//
//  Created by AndyDent on 5/4/21.
//

import Foundation
import SpriteKit

// simple model to support playing shaders
class SKShaderToyModel {
    #if os(macOS)
    private(set) static var defaultPlayingSize: CGSize = NSScreen.main?.frame.size  ?? CGSize(width: 400, height: 400) // reset on every startPlaying
    #else
    private(set) static var defaultPlayingSize: CGSize = UIScreen.main.bounds.size  // reset on every startPlaying
    #endif
    private(set) var playingSize = SKShaderToyModel.defaultPlayingSize
    var activeScene: SKScene? = nil
    var activeShaderNode: SKSpriteNode? = nil
    var shaderText: String = SKShaderToyModel.movingGradientShader
    var editDirty = false

    // copied from tgTouchgram.startPlaying
    func startPlaying(onView:SKView) {
        guard activeScene == nil else {return}  // safe to call repeatedly
        playingSize = onView.bounds.size
        let newScene = SKScene(size: playingSize)
        activeScene = newScene
        newScene.scaleMode = .aspectFill
        updateShaderNode()
        onView.presentScene(newScene)
    }
    
    func updateShaderNode() {
        if let ash = activeShaderNode {
            ash.removeFromParent()
            activeShaderNode = nil
        }
        if let newNode = makeShaderNode(fitting: playingSize) {
            activeShaderNode = newNode
            activeScene?.addChild(newNode)
        }
    }
    
    // from tgShaderSource.makeSpriteNode
    func makeShaderNode(fitting fillSize:CGSize) -> SKSpriteNode? {
        guard let sh = makeShader() else {return nil}
        let ret = SKSpriteNode(color: .yellow, size: fillSize)
        ret.shader = sh
        ret.position = CGPoint(x:0.0, y:0.0)  // for anchor 0,0
        ret.anchorPoint = CGPoint(x: 0.0,y: 0.0)
        return ret
    }
    
    // from tgShaderSource.makeSKShader and makeSpriteNode
    func makeShader() -> SKShader? {
        guard shaderText.count > 4 else {return nil}
        //TODO uniforms support
        return SKShader(source: shaderText)
    }

    static let movingGradientShader = """
                                      void main() {
                                          // find the current pixel color
                                          vec2 uv = v_tex_coord;
                                          gl_FragColor = vec4(0.5 + 0.5*cos(u_time+uv.yxy),1.0);
                                      }
                                      """

}
