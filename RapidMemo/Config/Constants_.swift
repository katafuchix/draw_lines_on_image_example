//
//  Constants.swift
//  Useless
//
//  Created by cano on 2016/04/29.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

struct Constants {
    //static let COGNITO_REGIONTYPE = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "us-east-1:5aad27d0-9f34-40b1-aff9-bd507ecd5484"
    static let APP_NAME = "paintlite"
    static let APP_ID   = "abe25a66576a41268bd12693d17151af"
    
    static let textFieldSize = CGRect(x: 10, y: 10, width: 160, height: 35)
    
    static let settingTextFieldSize = CGRect(x: 0,y: 0,width: 200,height: 40)
    
    static let pickerSize    = CGRect(x: 0, y: 0, width: 200, height: 50)
    
    static let buttonSize    = CGRect(x: 0, y: 0, width: 140, height: 40)
    
    static let colorPickerSize = CGRect(x: 0,y: 0,width: 230,height: 30)
    
    static let colorViewSize = CGRect(x: 0,y: 0,width: 200,height: 40)
    
    static let popUpWidth : CGFloat    = 260.0
    
    static let pickerFontSize : CGFloat    = 18.0
    
    static let buttonFontSize : CGFloat    = 18.0
    
    static let langs = ["en","jp"]
    
    static let dateformats = ["MM/dd", "M/d", "M月d日"]//, "MM月dd日"]
    
    static let weekday_langs = ["en", "jp", "None"]//, "MM月dd日"]
    
    static let center_dateformats = ["YYYY/MM/dd", "YYYY/M/d", "YYYY年M月d日", "YYYY年MM月dd日"]//, "MM月dd日"]
    
    static let font_size = [14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
    
    static let encodings = ["UTF-8","Shift_JIS"]
    
    static let image_sizes = ["S","M", "L"]
    
    static let animation = ["on","off"]
    
    static let font_names_jp = [
        "Helvetica",
        "HigashiOme-Gothic",
        "YasashisaGothic",
        "Honoka-Maru-Gothic",
        "Honoka-Antique-Kaku",
        "Honoka-Mincho",
        "Koku-Mincho",
        "Shin-comic-tai",
        "SmartFontUI",
        "Koruri-Regular",
        "uzura_font",
        "JK-Gothic",
        "santyoume-font",
        "TanukiMagic",
        "NicoMoji+"
    ]
    
    static let font_names = [
                                "Helvetica",
                                "HigashiOme-Gothic",
                                "YasashisaGothic",
                                "Honoka-Maru-Gothic",
                                "Honoka-Antique-Kaku",
                                "Honoka-Mincho",
                                "Koku-Mincho",
                                "Shin-comic-tai",
                                "SmartFontUI",
                                "Koruri-Regular",
                                "uzura_font",
                                "JK-Gothic",
                                "santyoume-font",
                                "TanukiMagic",
                                "NicoMoji+"
                            ]
    
    static let font_values = [
                                "Helvetica",
                                "HigashiOme-Gothic",
                                "07YasashisaGothic",
                                "Honoka-Maru-Gothic",
                                "Honoka-Antique-Kaku",
                                "Honoka-Mincho",
                                "Koku-Mincho-Regular",
                                "F910-Shin-comic-tai",
                                "03SmartFontUI",
                                "Koruri-Regular",
                                "uzura_font",
                                "JK-Gothic-L",
                                "santyoume-font",
                                "Tanuki-Permanent-Marker",
                                "NicoMoji+"
                            ]
    
    /*
     ドル	$
     ポンド	£
     ユーロ	€
     円	¥
     ウォン	₩
     */
    static let currency_symbols = ["¥","$","£","£","₩","None"]
    
}
