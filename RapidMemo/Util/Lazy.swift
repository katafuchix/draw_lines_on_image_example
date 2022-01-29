//
//  Lazy.swift
//

import UIKit

func getAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func getWindowRootVC() -> UIViewController? {
    var root = UIApplication.shared.keyWindow?.rootViewController
    while root?.presentedViewController != nil {
        root = root?.presentedViewController
    }
    return root
}

func findRootVCIfNavigation(_ vc: UIViewController) -> UIViewController? {
    if vc.isKind(of: UINavigationController.self) {
        return (vc as! UINavigationController).viewControllers.first
    }
    return vc
}

func simpleAlert(_ vc: UIViewController? = nil, title: String?, message: String?, closeTitle: String? = "閉じる", handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: closeTitle, style: .cancel, handler: handler))
    
    var vc = vc
    if vc == nil {
        vc = getWindowRootVC()
    }
    vc!.present(alert, animated: true, completion: nil)
}

func simpleAlertWithColor(_ vc: UIViewController? = nil, title: String?, message: String?, closeTitle: String? = "閉じる", handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    var myMutableString = NSMutableAttributedString()
    myMutableString = NSMutableAttributedString(string: title!, attributes: [NSAttributedStringKey.font:UIFont(name: "HiraMaruProN-W4", size: 16)!])
    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSRange(location:0,length:(title?.characters.count)!))
    alert.setValue(myMutableString, forKey: "attributedTitle")
    
    var messageMutableString = NSMutableAttributedString()
    messageMutableString = NSMutableAttributedString(string: message! , attributes: [NSAttributedStringKey.font:UIFont(name: "HiraMaruProN-W4", size: 14)!])
    messageMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSRange(location:0,length:(message?.characters.count)!))
    alert.setValue(messageMutableString, forKey: "attributedMessage")
    
    let cancelAction = UIAlertAction(title: closeTitle, style: .cancel, handler: handler)
    cancelAction.setValue(UIColor.gray, forKey: "titleTextColor")
    alert.addAction(cancelAction)
    
    var vc = vc
    if vc == nil {
        vc = getWindowRootVC()
    }
    vc!.present(alert, animated: true, completion: nil)
}

func makeRandom(min: Int, max: Int) -> Int {
    let diff = max - min + 1
    let rdm = arc4random_uniform(UInt32(diff))
    return Int(rdm) + min
}
    
/// クリップボードへのコピー
func copyClipboard(_ text: String) {
    UIPasteboard.general.setValue(text, forPasteboardType: "public.text")
}
