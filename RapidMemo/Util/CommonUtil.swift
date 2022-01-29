//
//  CommonUtil.swift
//  Useless
//
//  Created by cano on 2016/03/18.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation
import UIKit

open class CommonUtil {

    open static let DEFAULT_FONT_NAME_JP = "HiraKakuProN-W3"
    open static let DEFAULT_FONT_NAME_EN = "Helvetica"
    open static let NAVBAR_TRANSLUCENT = false // ナビゲーションバーの透過効果
    open static let TABLE_WIDTH_KEY = "TABLE_WIDTH"
    open static let RIGHT_DIFF_KEY = "RIGHT_DIFF"
    open static let HOUR_WIDTH_KEY = "HOUR_WIDTH"
    open static let RECORD_DIFF_KEY = "RECORD_DIFF"
    open static var rightDiff:CGFloat = 0.0
    open static var hourWidth:CGFloat = 0.0
    open static var tableWidth:CGFloat = 0.0
    
    open static let colorRed = UIColor(red: 140 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
    
    //チュートリアルを表示したかどうか
    open static let TUTORIAL_TITLE = "TUTORIAL_TITLE"
    //予定追加チュートリアルを表示したかどうか
    open static let TUTORIAL_ADD = "TUTORIAL_ADD"
    
    // テーマカラー保存用のキー
    static let THEMA_COLOR_KEY = "THEMA_COLOR_KEY"
    
    // カレンダー曜日色表示
    static let SAT_COLOR_KEY = "SAT_COLOR_KEY"
    static let SUN_COLOR_KEY = "SUN_COLOR_KEY"

    // テーマカラーを保存
    open static func setThemaColor(_ str:String) {
        let ud = UserDefaults.standard
        ud.set(str, forKey: CommonUtil.THEMA_COLOR_KEY)
        ud.synchronize()
    }
    
    // テーマカラーを取得
    open static func getThemaColor() -> String {
        let ud = UserDefaults.standard
        let val = ud.string(forKey: CommonUtil.THEMA_COLOR_KEY)
        //print(val)
        if val != nil {
            return val!
        }else{
            // 設定がなければデフォルトの色を返す
            return String("000000")
            //UIColor(hex:Int("9036028")!, alpha:1.0)
        }
    }
    
    // 設定してるテーマカラーの取得
    open static func getSettingThemaColor() -> UIColor {
        let defaultColor = CommonUtil.getThemaColor()
        if(defaultColor != ""){
            //return UIColor(hex: Int(defaultColor)!, alpha: 1.0)
            return self.getUIColorFromString(defaultColor)
        }else{
            // 設定がなければデフォルトの色を返す
            //return UIColor(hex:Int("9025020")!, alpha:1.0)
            return UIColor.black
        }
    }
    
    open static func getUIColorFromString(_ str:String) -> UIColor {
        
        var vals = str.components(separatedBy: " ")
        if vals.count < 4{
            return UIColor.black
        }
        
        let red     = CGFloat(Float(vals[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String)!)
        let green   = CGFloat(Float(vals[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String)!)
        let blue    = CGFloat(Float(vals[2].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String)!)
        let alpha   = CGFloat(Float(vals[3].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as String)!)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // 言語情報を取得
    open static func getLocaleLang() -> String {
        let info = Locale.current.identifier  // jp_JA ja_US en_US 等
        var splitval = info.components(separatedBy: "_")
        return splitval[0]
    }
    
    // 言語がjaか？
    open static func isJa() -> Bool {
        return getLocaleLang() == "ja"
    }
    /*
    // 金額表示
    static func addFigure(config:Config, value:Float) -> String{
        
        let num = NSNumber(float:value)
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        let result = formatter.stringFromNumber(num)
        
        if config.currency_symbol != "None" {
            return  "\(config.currency_symbol) \(result!)"
        }else{
            return result!
        }
    }
    */
}
