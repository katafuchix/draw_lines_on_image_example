//
//  ColorPickerViewController.swift
//  PaintLiteSwift
//
//  Created by cano on 2017/09/30.
//  Copyright © 2017年 mycompany. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPicker: ChromaColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        let homeButton : UIBarButtonItem = UIBarButtonItem(title: "LeftButtonTitle", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ColorPickerViewController.onClose(_:)))
        homeButton.image = UIImage.init(icon: "fa-times", backgroundColor: UIColor.clear, iconColor: UIColor.black, fontSize: 32)
        homeButton.tintColor = .black
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "RigthButtonTitle", style: UIBarButtonItemStyle.plain, target: self, action:#selector(ColorPickerViewController.onColor(_:)))
        logButton.image = UIImage.init(icon: "fa-check", backgroundColor: UIColor.clear, iconColor: UIColor.black, fontSize: 32)
        logButton.tintColor = .black
 
        self.navigationItem.leftBarButtonItem = homeButton
        self.navigationItem.rightBarButtonItem = logButton
         */
        colorPicker.delegate = self //ChromaColorPickerDelegate
        colorPicker.padding = 5
        colorPicker.stroke = 3
        colorPicker.hexLabel.textColor = UIColor.black
        colorPicker.adjustToColor(CommonUtil.getSettingThemaColor())
        
    }
    
    @objc func onClose(_ sender:Any){
        self.dismiss(animated: true, completion: nil)
    }
    @objc  
    func onColor(_ sender:Any){
        dismissWithColor()
        //self.dismiss(animated: true, completion: nil)
    }
    
    func dismissWithColor(){
        /*if let nc = self.presentingViewController as? UINavigationController {
            if let vc = nc.viewControllers[0] as? ViewController {
                let colorRef = colorPicker.currentColor.cgColor
                let colorString = CIColor(cgColor: colorRef).stringRepresentation
                CommonUtil.setThemaColor(colorString)
                self.dismiss(animated: true, completion: nil)
                vc.addDrawView()
            }
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ColorPickerViewController : ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor){
        self.dismissWithColor()
    }
}
