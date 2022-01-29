//
//  PublicDatas.swift
//  MapSample
//
//  Created by cano on 2016/02/20.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

// NSUserDefaultを共通して使うためのインターフェース用のクラス
open class PublicDatas: NSObject {
    
    static var instance : PublicDatas? = nil
    var ud : UserDefaults?
    
    // インスタンス取得
    static func getPublicDatas() -> PublicDatas {
        if instance == nil {
            instance = PublicDatas()
        }
        return instance!
    }
    
    // 初期化処理
    required public override init () {
        super.init()
        ud = UserDefaults.standard
    }
    
    // 値をセット 全ての型で共通して利用
    func setData(_ value:AnyObject, key:String){
        ud!.set(value, forKey:key)
        ud!.synchronize()
    }
    
    // 型を指定せずに値を取得
    func getDataForKey(_ key:String)->AnyObject?{
        if ud?.object(forKey: key) != nil {
            return (ud?.object(forKey: key))! as AnyObject?
        }else{
            return nil
        }
    }
    
    // Stringで値を取得
    func getStringForKey(_ key:String)->String!{
        if ud!.object(forKey: key) != nil {
            return ud!.object(forKey: key) as! String
        }else{
            return ""
        }
    }
    
    // Intで値を取得
    func getIntegerForKey(_ key:String)->Int!{
        if ud!.object(forKey: key) != nil {
            return ud!.object(forKey: key) as! Int
        }else{
            return 0
        }
    }
    
    // Floatで値を取得
    func getFloatForKey(_ key:String)->Float!{
        if ud!.object(forKey: key) != nil {
            return ud!.object(forKey: key) as! Float
        }else{
            return 0.0
        }
    }
    
    // Bool型で値を取得
    func getBoolForKey(_ key:String)->Bool!{
        if ud!.object(forKey: key) != nil {
            return ud!.object(forKey: key) as! Bool
        }else{
            return false
        }
    }
    /*
    // NSDate型で値を取得
    public func getNSDateForKey(key:String)->NSDate?{
        if let d = ud!.objectForKey(key) as? NSDate {
            return d
        }else{
            return DateUtil.getBlankDate()
        }
    }
    */
    // NSDate型で値を取得
    open func getUIColorForKey(_ key:String)->UIColor?{
        if let d = ud!.object(forKey: key) as? UIColor {
            return d
        }else{
            return UIColor.black
        }
    }
}

/*
public class PublicDatas: NSObject{

    static var instance : PublicDatas? = nil
    var dictionary : Dictionary<String,AnyObject>?
    
    static func getPublicDatas() -> PublicDatas {
        if instance == nil {
            instance = PublicDatas()
        }
        return instance!
    }
    
    required public override init () {
        super.init()
        dictionary = Dictionary<String,AnyObject>()
    }
    
    func setData(value:AnyObject, key:String){
        let lock = AutoSync(self)
        dictionary![key] = value
    }
    
    func getData(key:String)->AnyObject{
        return (dictionary?[key])!
    }
}

class AutoSync {
    let object : AnyObject
    
    init(_ obj : AnyObject) {
        object = obj
        objc_sync_enter(object)
    }
    
    deinit {
        objc_sync_exit(object)
    }
}
*/
