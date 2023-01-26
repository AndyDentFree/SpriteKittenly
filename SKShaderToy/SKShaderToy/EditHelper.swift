//
//  EditHelper.swift
//  SKShaderToy
//
//  Created by AndyDent on 5/5/21.
//

import Foundation
import UIKit
import os.log

protocol EditHelper : AnyObject {
    func setupScrollForKeyboard()
    func adjustForKeyboardHide()
    func adjustForKeyboardResize(notification: Notification)
    var bottomOutletToAdjust: NSLayoutConstraint! {get}  // bottom constraint of scrollview resized when keyboard shown
    var saveOutletOffset: CGFloat {get set}
}


extension EditHelper where Self:UIViewController {

    func setupScrollForKeyboard() {
        saveOutletOffset = bottomOutletToAdjust?.constant ?? 0.0
        // note do NOT try using #selector as you cannot within extensions, this is the closure-based alternative
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue:nil) {
            [weak self] notification in
            self?.adjustForKeyboardHide()
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue:nil) {
            [weak self] notification in
            self?.adjustForKeyboardResize(notification:notification)
        }
    }

    func adjustForKeyboardHide() {
        guard let bot = bottomOutletToAdjust else {
            os_log("Unable to adjustForKeyboardHide as no bound outlet",  type:.debug)
            return
        }
        os_log("Keyboard hidden, resetting layout constant", type:.debug)
        bot.constant = saveOutletOffset
    }

    func adjustForKeyboardResize(notification: Notification) {
        guard let bot = bottomOutletToAdjust else {
            os_log("Unable to adjustForKeyboardResize as no bound outlet", type:.debug)
            return
        }
        guard let userInfo = notification.userInfo else { return }
        
        // cannot cache keyboard sizes as user may change keyboard types to trigger this
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        os_log("Keyboard resized, updating layout constant", type:.debug)
        bot.constant = max(keyboardViewEndFrame.height + 4, saveOutletOffset)  // when we are using beyond the normal scrollview adjustment, may have something that's already above the keyboard so don't want to drag it down.
    }

}
