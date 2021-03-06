//
//  UIAlertControllerExtenstion.swift
//  CosMaps
//
//  Created by kumagai on 2014/09/23.
//  Copyright (c) 2014年 CosDev. All rights reserved.
//

import Foundation
import UIKit

/**
* UIAlertActionをカンタンに追加するための拡張
*/
extension UIAlertController {
    
    /**
    アプリの設定画面を表示するためUIAlertControllerを作成する
    
    :param: message アラートメッセージのキー
    :return: アラートスタイルのUIAlertController
    */
    public class func settingsAlertWithMessage(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        alert.addDefaultAction(title: NSLocalizedString("AlertActionTitleSettings", comment: "")) { action in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }
        return alert
    }
    
    

    /**
    タイトルを指定してアクションシートスタイルのUIAlertControllerを作成する
    
    :param: title アクションシートタイトルのキー
    :return: アクションシートスタイルのUIAlertController
    */
    public class func actionSheetWithTitle(title: String? = nil) -> UIAlertController {
        return actionSheet(title: title, message: nil)
    }
    
    /**
    メッセージを指定してアクションシートスタイルのUIAlertControllerを作成する
    
    :param: message アクションシートメッセージのキー
    :return: アクションシートスタイルのUIAlertController
    */
    public class func actionSheetWithMessage(message: String? = nil) -> UIAlertController {
        return actionSheet(title: nil, message: message)
    }
    
    /**
    タイトル、メッセージを指定してアクションシートスタイルのUIAlertControllerを作成する
    
    :param: title アクションシートタイトルのキー
    :param: message アクションシートメッセージのキー
    :return: アクションシートスタイルのUIAlertController
    */
    public class func actionSheet(#title: String?, message: String?) -> UIAlertController {
        return UIAlertController(title: title != nil ? NSLocalizedString(title!, comment: "") : title,
                               message: message != nil ? NSLocalizedString(message!, comment: "") : message,
                        preferredStyle: .ActionSheet)
    }

    /**
    タイトルを指定してアラートスタイルのUIAlertControllerを作成する
    
    :param: title アラートタイトルのキー
    :return: アラートスタイルのUIAlertController
    */
    public class func alertWithTitle(#title: String) -> UIAlertController {
        return UIAlertController(title: NSLocalizedString(title, comment: ""),
            message: nil,
            preferredStyle: .Alert)
    }
    
    /**
    DefaultスタイルのUIAlertActionを追加する。
    
    :param: title   アクションのタイトル
    :param: handler クリックハンドラ
    */
    public func addDefaultAction(#title: String, handler: ((UIAlertAction!) -> Void)!) {
        addAction(title: title, style: .Default, handler: handler)
    }
    
    /**
    Cancelスタイルのアクションを追加する。
    
    :param: title   アクションのタイトル
    :param: handler クリックハンドラ
    */
    public func addCancelAction(#title: String, handler: ((UIAlertAction!) -> Void)!) {
        addAction(title: title, style: .Cancel, handler: handler)
    }
    
    /**
    Destructiveスタイルのアクションを追加する。
    
    :param: title   アクションのタイトル
    :param: handler クリックハンドラ
    */
    public func addDestructiveAction(#title: String, handler: ((UIAlertAction!) -> Void)!) {
            addAction(title: title, style: .Destructive, handler: handler)
    }
    
    /**
    UIAlertActionを追加する
    
    :param: title   アクションのタイトル
    :param: style   アクションのスタイル
    :param: handler クリックハンドラ
    */
    public func addAction(#title: String, style:UIAlertActionStyle, handler: ((UIAlertAction!) -> Void)!) {
        self.addAction(UIAlertAction(title: title, style: style, handler: handler))
    }
}