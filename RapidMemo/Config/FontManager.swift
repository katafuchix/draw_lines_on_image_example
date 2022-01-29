//
//  FontManager.swift
//  Useless
//
//  Created by cano on 2016/05/10.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class FontManager {

    var font_names_jp   = [String]()
    var font_names      = [String]()
    var font_values     = [String]()
    
    
    // 初期化処理
    internal init(){
        font_names_jp   = [String]()
        font_names      = [String]()
        font_values     = [String]()
        
        //let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        // font.txtファイルを読み込み
        let path = Bundle.main.path(forResource: "font", ofType: "txt")!
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
            let str = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            
            // 改行で分割
            var valArray = str.components(separatedBy: "\n")
            //print(valArray[0])
            
            // 全体を回す
            for i in 0 ..< valArray.count {
                // ヘッダはスルー
                if i == 0 { continue }
                
                // , で各値に分割
                var vals = valArray[i].components(separatedBy: ",")
                font_names_jp.append(vals[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                font_names.append(vals[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                font_values.append(vals[2].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
        }
    }
}
