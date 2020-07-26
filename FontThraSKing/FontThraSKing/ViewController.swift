//
//  ViewController.swift
//  FontThraSKing
//
//  Created by Andrew Dent on 26/7/20.
//  Copyright © 2020 Touchgram. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {

    @IBOutlet weak var textDisplay: UILabel!
    @IBOutlet weak var textDisplaySerialised: UILabel!
    
    var demoText = "Demo text to display using font picked"
    var pickedFontDesc: UIFontDescriptor? = nil
    var fontSize: CGFloat = 24.0
    
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
            
            // easily get a font using the raw descriptor we just got back
            if let font = try? UIFont(descriptor:fd, size: fontSize) {
                os_log("Got a font: %s \nfrom descriptor: %s", font.description, fd.description)
                attStr.addAttribute(NSAttributedString.Key.font, value:font, range:allRange)
            }
            textDisplay.attributedText = NSAttributedString(attributedString:attStr)
            
            // try creating a descriptor from values as if had serialised
            let attr = fd.fontAttributes
            var attrs = [UIFontDescriptor.AttributeName:Any]()
            attrs[.size] = fontSize
            // painfully recreating as if had been serialised, so get stuff out to strings then back again
            if let pickedName = attr[.name] {
                let fontName = String(describing: pickedName)
                attrs[.name] = fontName
            } else if let pickedFamily = attr[.family] {
                let fontFam = String(describing: pickedFamily)
                attrs[.family] = fontFam
            }
            let fd2 = UIFontDescriptor(fontAttributes: attrs)
            if let font2 = try? UIFont(descriptor:fd2, size: fontSize) {
                let attStr = NSMutableAttributedString(string:demoText) // recreate the string
                os_log("Got a font: %s \nfrom descriptor: %s", font2.description, fd2.description)
                attStr.addAttribute(NSAttributedString.Key.font, value:font2, range:allRange)
                textDisplaySerialised.attributedText = NSAttributedString(attributedString:attStr)
            }

        } else {
            textDisplay.text = demoText
        }
        
    }

    /// Displays the font picker
    @IBAction func onPickFont(_ sender: UIButton) {
        let fc = UIFontPickerViewController.Configuration()
        fc.includeFaces = true
        let fp = UIFontPickerViewController(configuration: fc)
        fp.selectedFontDescriptor = pickedFontDesc
        fp.delegate = self
        self.present(fp, animated: true, completion: nil)
    }
    
}


extension ViewController : UIFontPickerViewControllerDelegate {
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        pickedFontDesc = viewController.selectedFontDescriptor
        viewController.dismiss(animated: true, completion: nil)
        updateDisplays()
    }
}
