//
//  EditShaderViewController.swift
//  SKShaderToy
//
//  Created by AndyDent on 5/4/21.
//

import UIKit
import SpriteKit

class EditShaderViewController: UIViewController {

    @IBOutlet weak var preview: SKView!
    @IBOutlet weak var shaderTextEntry: UITextView!
    var editModel = SKShaderToyModel()
    lazy var sharedModel = AppDelegate.model!

    override func viewDidLoad() {
        super.viewDidLoad()
        shaderTextEntry.delegate = self
        editModel.shaderText = sharedModel.shaderText
        shaderTextEntry.text = editModel.shaderText
        //shaderTextEntry.becomeFirstResponder() // if want keyboard to appear but that hides tab so confuses user too much
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editModel.startPlaying(onView: preview)
        // shaderTextEntry.text remembers prev value
        // so if return here without pressing Refresh, will stay different
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if sharedModel.shaderText != editModel.shaderText {
            sharedModel.shaderText = editModel.shaderText
            sharedModel.editDirty = true
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func onRefresh(_ sender: UIButton) {
        shaderTextEntry.endEditing(true)  // hides keyboard and enables tabs to be visible if have edited
        guard editModel.editDirty else {return}
        editModel.shaderText = shaderTextEntry.text
        editModel.editDirty = false
        editModel.updateShaderNode()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension EditShaderViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        editModel.editDirty = true
    }
}
