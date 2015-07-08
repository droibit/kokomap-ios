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
* @brief UIAlertActionをカンタンに追加するための拡張
*
* @author kumagai
* @since 2014/09/23
* @version 1.0.0
*/
extension UIAlertController {
    
    // MARK: Extenstion Methods
    
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