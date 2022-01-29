//
//  ViewController.swift
//  PaintLiteSwift
//
//  Created by cano on 2016/06/15.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import AVFoundation
//import CNPPopupController
import QuartzCore
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, imageSelectDelegate {
    
    @IBOutlet weak var ImageBarButton: UIBarButtonItem!
    @IBOutlet weak var SaveBarButton: UIBarButtonItem!
    @IBOutlet weak var UndoBarButton: UIBarButtonItem!
    @IBOutlet weak var LineBarButton: UIBarButtonItem!
    @IBOutlet weak var ColorBarButton: UIBarButtonItem!
    
    //@IBOutlet weak var imageView: UIImageView!
    var imageView: UIImageView?
    
    var imagePicker = UIImagePickerController()
    
    //var popupController:CNPPopupController? = nil//CNPPopupController()
    let pData = PublicDatas.getPublicDatas()
    var colorView: UIView?
    
    //var colorPicker: ColorPicker?
    //var huePicker: HuePicker?
    
    //var drawBase : DrawBase?
    
    @IBOutlet weak var widthView: UIView!
    @IBOutlet weak var widthSlider: UISlider!
    var isShowWidthView : Bool = false
    @IBOutlet weak var widthViewTopConstraint: NSLayoutConstraint!
    
    var whiteImage : UIImage?
    
    //var vc : DRColorPickerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.presentImagseSelectView()
        
        ImageBarButton.action = #selector(ViewController.onImage(_:))
        SaveBarButton.action  = #selector(ViewController.onSave(_:))
        UndoBarButton.action  = #selector(ViewController.onUndo(_:))
        LineBarButton.action = #selector(ViewController.onLine(_:))
        ColorBarButton.action  = #selector(ViewController.onColor(_:))
        
        //widthSlider.layer.masksToBounds = true
        //widthSlider.layer.cornerRadius = 50
        widthSlider.minimumValue = 0.5
        widthSlider.maximumValue = 40.0
        let w = pData.getFloatForKey("width")
        if  w > 0.0 {
            widthSlider.value = w!
        }else{
            widthSlider.value = 10.0
            pData.setData(10.0 as AnyObject, key: "width")
        }
        widthSlider.addTarget(self, action: #selector(ViewController.onChgSlider(_:)), for: UIControlEvents.valueChanged)
        
        imageView = UIImageView(frame:CGRect(x: 0,y: 0, width: self.view.frame.width, height: self.view.frame.height - 44.0))
        self.imageView!.contentMode = .scaleToFill
        self.view.addSubview(imageView!)
        //let whiteView = UIView(frame:CGRectMake(0,0, self.view.frame.width, self.view.frame.height - 44.0))//
        let whiteView = UIView(frame:self.imageView!.bounds)
        whiteView.backgroundColor = UIColor.white
        self.whiteImage = self.captureImage(whiteView)
        self.imageView!.image = whiteImage
        addDrawView()
        
        self.view.sendSubview(toBack: imageView!)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func captureImage(_ view:UIView)->UIImage{
        return UtilManager.getUIImageFromUIView(view)
    }
    
    func addDrawView() {
        let r = AVMakeRect(aspectRatio: self.imageView!.image!.size, insideRect: self.imageView!.frame)
        let drawBase = DrawBase(frame:r)
        imageView!.isUserInteractionEnabled = true
        drawBase.isUserInteractionEnabled = true
        self.imageView!.addSubview(drawBase)
    }
    
    @objc func onLine(_ sender:AnyObject) {
        if isShowWidthView {
            hideWidthView()
        }else{
            showWidthView()
        }
    }
    
    func showWidthView(){
        self.view.sendSubview(toBack: imageView!)
        self.view.bringSubview(toFront: widthSlider)
        UIView.animate(withDuration: 0.2, animations: {
            self.widthViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
            },completion: {
                finished in
                self.isShowWidthView = true
        })
    }
    
    func hideWidthView(){
        UIView.animate(withDuration: 0.4, animations: {
            self.widthViewTopConstraint.constant -= 100
            self.view.layoutIfNeeded()
            }, completion: {
                finished in
                //self.blackOutView!.hidden = true
                self.isShowWidthView = false
        } )
    }
    
    @objc func onChgSlider(_ sender:UISlider){
        pData.setData(sender.value as AnyObject, key: "width")
    }
    
    @objc func onImage(_ sender:AnyObject){
        presentImagseSelectView()
    }
    
    func presentImagseSelectView(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            imagePicker.navigationBar.isTranslucent = false
            imagePicker.navigationBar.barStyle = .black
            imagePicker.navigationBar.tintColor = UIColor.white
            imagePicker.navigationBar.backgroundColor = .black
            imagePicker.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "cropper-vc") as! CropperViewController
            vc._image = pickedImage
            vc.delegate = self
            picker.pushViewController(vc, animated: true)
        }
    }
    
    func selectImage(_ image:UIImage) {
        //print("select")
        self.imageView!.contentMode = .scaleAspectFit
        
        for view in self.imageView!.subviews{
            if view.isKind(of: DrawBase.self) {
                view.removeFromSuperview()
            }
        }
        //drawBase?.removeFromSuperview()
        imageView!.image = image
        
        addDrawView()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onSave(_ sender:AnyObject){
        
        //let reSize = CGSizeMake(self.imageView.frame.size.width * CGFloat(2), self.imageView.frame.size.height * CGFloat(2))
        //let saveImage = self.imageView.image.resize(reSize)
        
        /*
        let im = UtilManager.getUIImageFromUIView(self.imageView)
        UIImageWriteToSavedPhotosAlbum(im, self, "image:didFinishSavingWithError:contextInfo:", nil)
        */
        //print(imageView!.frame)
        let r = AVMakeRect(aspectRatio: self.imageView!.image!.size, insideRect: self.imageView!.frame)
        //print(r)
        //let im = UtilManager.getUIImageFromUIView(self.imageView!)
        /*
        let size = imageView.frame.size//CGSizeMake(CGFloat(r.width), CGFloat(r.height))
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        im.drawInRect(r)
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        */
        
        //let resizeImage = im.getImageInRect(r)
        
        // self.viewを画像化
        let viewImg = UtilManager.getUIImageFromUIView(self.view)
        let resizeImage = self.cropImage(viewImg, rect:r)
        UIImageWriteToSavedPhotosAlbum(resizeImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // 画像保存時のセレクタ
    func image(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        
        var message : String?
        if error == nil {
            message = "successfully saved"
        }
        // 処理の完了時にはアラートを出す
        let alert = UIAlertController(title: message!, message: "", preferredStyle: .alert)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        // 表示
        present(alert, animated: true, completion: nil)
    }
    
    func cropImage(_ image:UIImage, rect:CGRect)->UIImage {
        let scale = image.scale
        
        let cliprect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale,
                                  width: rect.size.width * scale, height: rect.size.height * scale)
        // ソース画像からCGImageRefを取り出す
        let srcImgRef : CGImage = image.cgImage!
        
        // 指定された範囲を切り抜いたCGImageRefを生成しUIImageとする
        let imgRef : CGImage = srcImgRef.cropping(to: cliprect)!
        let resultImage : UIImage = UIImage(cgImage: imgRef, scale: scale, orientation: image.imageOrientation)
        
        // 後片付け
        //CGImageRelease(imgRef)
        return resultImage
    }
    
    @objc func onColor(_ sender:AnyObject){
        //self.showPopupWithStyle(CNPPopupStyle.actionSheet)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ColorNav") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
        return
        /*
        DRColorPickerBackgroundColor = UIColor.white
        DRColorPickerBorderColor = UIColor.black
        DRColorPickerFont = UIFont.systemFont(ofSize: 16.0)
        DRColorPickerLabelColor = UIColor.black
        DRColorPickerStoreMaxColors = 200
        DRColorPickerShowSaturationBar = true
        DRColorPickerHighlightLastHue = true
        DRColorPickerUsePNG = false
        DRColorPickerJPEG2000Quality = 0.9
        //DRColorPickerSharedAppGroup = nil
        
        vc = DRColorPickerViewController.newColorPicker(with: DRColorPickerColor(color: CommonUtil.getSettingThemaColor()))
        //vc.modalPresentationStyle = UIModalPresentationForm.Sheet
        vc?.rootViewController.showAlphaSlider = true
        
        vc?.rootViewController.addToFavoritesImage = nil;
        vc?.rootViewController.favoritesImage = nil;
        vc?.rootViewController.hueImage = nil;
        vc?.rootViewController.wheelImage = nil;
        vc?.rootViewController.importImage = nil;
        
        vc?.rootViewController.dismissBlock = { result in
            let color = self.vc?.rootViewController.color.rgbColor
            print(color)
            let colorRef = color?.cgColor
            print(colorRef)
            let colorString = CIColor(cgColor: colorRef!).stringRepresentation
            print(colorString)
            CommonUtil.setThemaColor(colorString)
            self.dismiss(animated: true, completion: nil)
            self.addDrawView()
        }
        
        self.present(vc!, animated: true, completion: nil)
         */
    }
    
    /*
    // テーマカラー
    func showPopupWithStyle(_ popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 140, height: 40))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 17)!
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 17)!
        button.setTitle("SAVE", for: UIControlState())
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = UIColor.gray//CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            //print("Block for button: \(button.titleLabel?.text)")
            self.pData.setData(String(UIColor.toInt32(self.colorView!.backgroundColor!)) as AnyObject, key: "themaColor")
            CommonUtil.setThemaColor(String(UIColor.toInt32(self.colorView!.backgroundColor!)))
            
            self.addDrawView()
        }
        
        let cl : SwiftHUEColorPicker = SwiftHUEColorPicker()
        cl.delegate = self
        cl.frame = Constants.colorPickerSize
        print(cl.frame)
        cl.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        cl.type = SwiftHUEColorPicker.PickerType.color
        cl.currentColor = CommonUtil.getSettingThemaColor()
        cl.backgroundColor = UIColor.white
        
        colorPicker = ColorPicker(frame:CGRect(x: 0,y: 0,width: 220,height: 50))
        huePicker = HuePicker(frame:CGRect(x: 0,y: 0,width: 220,height: 20))
        
        let color = CommonUtil.getSettingThemaColor()
        colorView = UIView(frame:Constants.colorViewSize)
        colorView?.backgroundColor = color
        
        let pickerController = ColorPickerController(svPickerView: colorPicker!, huePickerView: huePicker!, colorWell: ColorWell())
        pickerController.color = CommonUtil.getSettingThemaColor() //UIColor.redColor()
        
        pickerController.onColorChange = {(color, finished) in
            if finished {
                //self.view.backgroundColor = UIColor.whiteColor() // reset background color to white
            } else {
                self.colorView!.backgroundColor = color // set background color to current selected color (finger is still down)
            }
        }
        
        self.popupController = CNPPopupController(contents:[
            UIView(),
            colorPicker!,huePicker!,UIView(),colorView!,UIView(),button, UIView()
            ])
        self.popupController.theme = CNPPopupTheme.default()
        self.popupController.theme.popupStyle = CNPPopupStyle.centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.present(animated: true)
    }
    */
    
    /*
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        colorView?.backgroundColor = color
    }
    
    func setPopupSize(){
        self.popupController.theme.maxPopupWidth = 260.0//UtilManager.getPopUpWidth()
    }
    */
    
    @objc func onUndo(_ sender:AnyObject){
        let drawBase = self.imageView?.subviews.last as! DrawBase
        print(drawBase)
        drawBase.undoButtonClicked()
        if drawBase.paths.count == 0 && self.imageView?.subviews.count > 1 {
            drawBase.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

