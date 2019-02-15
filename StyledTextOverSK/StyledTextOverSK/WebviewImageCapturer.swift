//
//  WebviewImageCapturer.swift
//  StyledTextOverSK
//
//  Created by Andrew Dent on 14/2/19.
//  Copyright © 2019 Aussie Designed Software Pty Ltd. All rights reserved.
//

import SpriteKit
import WebKit

class WebviewImageCapturer : NSObject, WKNavigationDelegate {
    var scene:SKScene
    var imgSpriteOfHtml: SKSpriteNode? = nil
    
    init(scene:SKScene) {
        self.scene = scene
    }
    
    func removeFromParent() {
        imgSpriteOfHtml?.removeFromParent()
        imgSpriteOfHtml = nil
    }

    /*
     Works on simulator but not on iOS 12 devices
     */
    func webView(_ webview:WKWebView, didFinish: WKNavigation!) {
         // https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview
        if #available(iOS 11.0, *) {
             webview.takeSnapshot(with: nil) {[weak self] image, error in
                 webview.navigationDelegate = nil
                 webview.removeFromSuperview()
                 if let image = image,
                 let scene = self?.scene {
                     print(image.size)
                     let sprite = SKSpriteNode(texture:SKTexture(image: image), size:scene.size)
                     scene.addChild(sprite)
                     self?.imgSpriteOfHtml = sprite
                 }
                 else {
                    print(error!)
                 }
            }
        }  // ios 11 or above
        else {
            // just cleanup
            webview.navigationDelegate = nil
            webview.removeFromSuperview()
        }
     }
    
    /**
     BROKEN VERSION
     func webView(_ webview:WKWebView, didFinish: WKNavigation!) {
     var sprite:SKSpriteNode? = nil
     UIGraphicsBeginImageContextWithOptions(scene.size, false, 0.0)  // !opaque and scaled to device main screen
     // still gets nothing but blank background on device - either of the next two approaches
     webview.layer.render(in: UIGraphicsGetCurrentContext()!)
     //webview.drawHierarchy(in: scene.frame, afterScreenUpdates: true)
     if let img = UIGraphicsGetImageFromCurrentImageContext() {
     sprite = SKSpriteNode(texture:SKTexture(image: img), size:scene.size)
     }
     UIGraphicsEndImageContext()
     // just feel a bit better updating SpriteKit scene after closing the image context
     webview.navigationDelegate = nil
     webview.removeFromSuperview()
     if let imgSprite = sprite {
     scene.addChild(imgSprite)
     self.imgSpriteOfHtml = imgSprite
     }
     }
     */

}
