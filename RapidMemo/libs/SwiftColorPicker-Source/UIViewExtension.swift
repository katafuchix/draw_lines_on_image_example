//
//  UIViewExtension.swift
//  FreeNow
//
//  Created by k.katafuchi on 2016/02/29.
//  Copyright © 2015年 FreeNow Inc. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    
    // 線を引くメソッド
    public func drawLine(_ from: CGPoint,
                            to: CGPoint,
                            width: CGFloat = 40.0,//EventTableViewCell.EVENT_CELL_BORDER_WIDRH,
                            color: UIColor = UIColor.gray,//EventTableViewCell.colorGray,
                            diff: CGFloat = 0.0
        )
    {
        var fromv = from
        var tov = to
        
        //アンチエイリアスを無効にするために座標調整
        if diff > 0.0 {
            fromv.x += diff
            fromv.y += diff
            tov.x += diff
            tov.y += diff
        }
        
        let line = UIBezierPath()
        line.move(to: fromv)
        line.addLine(to: tov)
        color.setStroke()
        line.lineWidth = width
        line.stroke();
    }
    
    //色の四角を描画する
    public func drawColorRect(_ rect:CGRect, color: UIColor) {
        let rectangle = UIBezierPath(rect: rect)
        color.setFill()
        rectangle.fill()
    }
    
    // 背景を白で塗りつぶして初期化する
    public func drawWhiteBackground(_ rect:CGRect) {
        let cell_rectangle = UIBezierPath(rect: rect)
        UIColor.white.setFill()
        cell_rectangle.fill()
    }
    
    // 円を描く
    public func drawCircle(_ rect:CGRect, color:UIColor) {
        let circle = UIBezierPath(ovalIn: rect)
        color.setFill()
        circle.fill()
    }
    
    public func copyView() -> AnyObject
    {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
    }
}

