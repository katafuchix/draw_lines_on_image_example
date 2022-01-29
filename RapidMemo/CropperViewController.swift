//
//  CropperViewController.swift
//  PaintLiteSwift
//
//  Created by cano on 2016/06/15.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class CropperViewController: UIViewController, AKImageCropperViewDelegate {

    var delegate : imageSelectDelegate?
    
    var _image: UIImage!
    
    @IBOutlet weak var cropView: AKImageCropperView!
    
    @IBOutlet weak var cropFrameBarButton: UIBarButtonItem!
    @IBOutlet weak var cropBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cropView.image = _image
        cropView.delegate = self
        
        cropFrameBarButton.action = #selector(CropperViewController.onCropFrame(_:))
        cropBarButton.action = #selector(CropperViewController.onCrop(_:))
    }
    
    @objc func onCrop(_ sender:AnyObject) {
        print(self.parent)
        
        // デリゲートが実装されていたら呼ぶ
        if (self.delegate?.responds(to: "selectImage:")) != nil {
            // 実装先のdidClose:メソッドを実行
            delegate?.selectImage(cropView.croppedImage!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onCropFrame(_ sender:AnyObject){
        //if cropView.overlayViewIsActive {
        if cropView.isOverlayViewActive {
            
            //cropFrameBarButton.setTitle("Show Crop Frame", forState: UIControlState.Normal)
            /*
            cropView.dismissOverlayViewAnimated(true) { () -> Void in
                
                print("Frame disabled")
            }
            */
            cropView.hideOverlayView(animationDuration: 0.3)
        } else {
            
            //cropFrameBarButton.setTitle("Hide Crop Frame", forState: UIControlState.Normal)
            /*
            cropView.showOverlayViewAnimated(true, withCropFrame: nil, completion: { () -> Void in
                
                print("Frame active")
            })*/
            cropView.showOverlayView(animationDuration: 0.3)
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveLinear, animations: {
                //self.overlayActionView.alpha = 1
                
            }, completion: nil)
        }
    }
    
    func cropRectChanged(_ rect: CGRect) {
        print("New crop rectangle: \(rect)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /**
         If you use programmatically initalization
         Switch 'cropView' to 'cropViewProgrammatically'\
         Example: cropViewProgrammatically.refresh()
         */
        //cropView.refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

protocol imageSelectDelegate : NSObjectProtocol {
    
    func selectImage(_ image:UIImage)
    
}
