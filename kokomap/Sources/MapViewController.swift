//
//  ViewController.swift
//  kokomap
//
//  Created by kumagai on 2015/06/30.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import UIKit
import MapKit

/**
 * 地図機能を提供するためのビューコントローラ
 *
 * @author kumagai
 */
class MapViewController: UIViewController {
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Action
    
    // Storyboard上で設定画面から戻る場合に必要
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        // データを受け渡しする場合はここで行う
    }
    
    // 現在位置に移動する際に呼ぶアクション
    @IBAction func onMoveCurrentLocation(sender: AnyObject) {
    }
    
    // 地図にマーカーを追加する際に呼ぶアクション
    @IBAction func onAddMarker(sender: AnyObject) {
    }
    
    // 地図の種類を変更する際に呼ぶアクション
    @IBAction func onChangeMapType(sender: AnyObject) {
    }
}

/**
 * MKMapViewのイベントをハンドルするための拡張
 */
extension MapViewController: MKMapViewDelegate {
    
    
}