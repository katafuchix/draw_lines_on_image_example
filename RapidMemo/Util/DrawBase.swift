//
//  DrawBase.swift
//  PaintLiteSwift
//
//  Created by cano on 2016/06/16.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class DrawBase: UIView {

    let pData = PublicDatas.getPublicDatas()
    
    var touchPoint:CGPoint?
    var currentPath:UIBezierPath?
    var drawColor:UIColor?
    
    var paths:Array<UIBezierPath>   = Array<UIBezierPath>()
    var paths2:Array<UIBezierPath>  = Array<UIBezierPath>()
    var widthArray:Array<CGFloat>   = Array<CGFloat>()
    var colorArray:Array<UIColor>   = Array<UIColor>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //drawColor = pData.getUIColorForKey("color")
        //drawColor?.set()
        
    }
    
    //描画処理
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //drawColor = CommonUtil.getSettingThemaColor()
        //drawColor?.set()
        
        for (index, path) in paths.enumerated() {
            path.lineWidth = widthArray[index]
            path.miterLimit = 10
            path.lineCapStyle = .round//kCGLineCapRound
            path.lineJoinStyle = .round//kCGLineJoinRound
            
            //UIColor.blackColor().setFill()
            //path.fill()
            
            let color = colorArray[index]
            color.set()
            path.stroke()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //print("start")
        currentPath = UIBezierPath()
        currentPath!.lineWidth = 3.0
        
        if let touch = touches.first {
            currentPath?.move(to: touch.location(in: self))
            paths.append(currentPath!)
            paths2.append(currentPath!)
            widthArray.append(CGFloat(pData.getFloatForKey("width")))
            colorArray.append(CommonUtil.getSettingThemaColor())
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("move")
        if let touch = touches.first {
            currentPath?.addLine(to: touch.location(in: self))
            self.setNeedsDisplay()
        }
    }
    
    func undoButtonClicked() {
        if paths.count > 0 {
            paths.removeLast()
            widthArray.removeLast()
            colorArray.removeLast()
        }
        self.setNeedsDisplay()
    }
}
