//
//  ViewController.swift
//  FontThraSKing
//
//  Created by Andrew Dent on 26/7/20.
//  Copyright © 2020 Touchgram. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textDisplay: UILabel!
    @IBOutlet weak var textDisplaySerialised: UILabel!
    
    var demoText = "Demo text to display using font picked"
    var pickedFontDesc: UIFontDescriptor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateDisplays()
    }
    
    /// Two labels show the same text
    func updateDisplays() {
        textDisplaySerialised.text = demoText

        if let fd = pickedFontDesc {
            let attStr = NSMutableAttributedString(string:demoText)
            let allRange = NSRange(location: 0, length: attStr.length)
            attStr.addAttribute(NSAttributedString.Key.font, value:fd, range:allRange)
            textDisplay.attributedText = NSAttributedString(attributedString:attStr)
        } else {
            textDisplay.text = demoText
        }
        
    }

    /// Displays the font picker
    @IBAction func onPickFont(_ sender: UIButton) {
        let fc = UIFontPickerViewController.Configuration()
        fc.includeFaces = true
        let fp = UIFontPickerViewController(configuration: fc)
        fp.delegate = self
        self.present(fp, animated: true, completion: nil)
    }
    
}


extension ViewController : UIFontPickerViewControllerDelegate {
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        pickedFontDesc = viewController.selectedFontDescriptor
        updateDisplays()
    }
}
