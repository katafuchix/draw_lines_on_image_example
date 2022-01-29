//
//  TwitterUtil.swift
//  RapidMemo
//
//  Created by cano on 2017/10/01.
//  Copyright © 2017年 cano. All rights reserved.
//

import UIKit

import Foundation
import Social
import Accounts
import SwiftyJSON

class TwitterUtil: NSObject {
    
    public static func post(_ image: UIImage, withDialog: Bool = true) {
        SVProgressHUD.show()
        if withDialog {
            let composeViewController: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            //composeViewController.setInitialText(param.productDescription)
            composeViewController.add(image)
            //.add(URL(string: param.landingPageUrl))
            SVProgressHUD.dismiss()
            UIApplication.shared.delegate?.window??.rootViewController?.present(composeViewController, animated: true, completion: nil)
        } else {
            
            self.getAccount(callback: { (twitterAccount) in
                self.uploadImage(account: twitterAccount, image:image, callback: { (mediaIdString, error) in
                    if error == nil {
                        let text = ""
                        //var text = param.productDescription
                        //text += " \(param.landingPageUrl)"
                        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
                        let params = ["status" : text, "media_ids": mediaIdString]
                        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                                requestMethod: .POST,
                                                url: url as URL!,
                                                parameters: params)
                        
                        // 取得したアカウントをセット
                        request?.account = twitterAccount
                        // APIコールを実行
                        request?.perform { (responseData, urlResponse, error) -> Void in
                            
                            if error != nil {
                                print("error is \(error)")
                                //simpleAlert(title: "シェアエラー", message: "シェアに失敗しました。")
                            }
                            else {
                                //simpleAlert(title: "シェア", message: "シェアが完了しました。")
                            }
                            SVProgressHUD.dismiss()
                        }
                    }
                })
            })
        }
    }
    
    private static func getAccount(callback: @escaping (ACAccount) -> Void) {
        let accountStore:ACAccountStore = ACAccountStore()
        let accountType:ACAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccounts(with: accountType, options: nil) {
            (success: Bool, error: Error?) -> Void in
            if error != nil {
                print("error! \(error.debugDescription)")
                return
            }
            
            if !success {
                simpleAlert(title: "シェアエラー", message: "Twitterアカウントの利用が許可されていません。")
                return
            }
            
            let accounts = accountStore.accounts(with: accountType) as! [ACAccount]
            if accounts.count == 0 {
                simpleAlert(title: "シェアエラー", message: "設定画面からアカウントを設定してください。")
                return
            }
            
            callback(accounts.first!)
        }
    }
    
    private static func uploadImage(account:ACAccount, image: UIImage, callback: @escaping (String?, Error?) -> Void) {
        let url = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")
        //let params = ["status" : text]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .POST,
                                url: url as URL!,
                                parameters: nil)
        request?.addMultipartData(UIImageJPEGRepresentation(image, 1.0), withName: "media", type: "image/jpeg", filename: "image.jpg")
        request?.account = account
        request?.perform(handler: { (data, response, error) in
            DispatchQueue.main.sync {
                if error != nil {
                    callback(nil, error)
                } else {
                    if let json = try? JSON(data: data!) {
                        callback(json["media_id_string"].rawValue as? String, nil)
                    }
                }
            }
        })
    }
    
}

