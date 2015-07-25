//
//  ViewController.swift
//  kokomap
//
//  Created by kumagai on 2015/06/30.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

private let kAnnotationId = "pin"
private let kMaxAlertSubtitleLength = 25

/**
 地図機能を提供するためのビューコントローラ
 */
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var snapshotter: Snapshotter!
    
    /// 現在位置情報（ボタン押下の都度ではなく、取得した位置を保持し、押下のタイミングで地図に設定）
    private var currentLocation: CLLocation? = nil
    /// マーカーを落とす座標（地図の中心）
    private var mapCenterCoordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    
    // MARK: Initializer
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Action
    
    // Storyboard上で設定画面から戻る場合に必要
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        // iPadの場合FormSheet形式で表示するとunwind segueが上手く動作しなかったので明示的に消す
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let settings = segue.sourceViewController as? SettingsViewController {
                settings.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // 現在位置に移動する際に呼ぶアクション。
    @IBAction func onMoveCurrentLocation(sender: AnyObject) {
        moveCurrentLocation()
    }
    
    // 地図にマーカーを追加する際に呼ぶアクション。
    @IBAction func onAddMarker(sender: AnyObject) {
        presentAdditionalMarkerActionSheet()
    }
    
    // 地図の種類を変更する際に呼ぶアクション。
    @IBAction func onChangeMapType(sender: AnyObject) {
        presentMapTypeActionSheet()
    }
}

// MARK: - ActionSheet
extension MapViewController: UITextFieldDelegate {
 
    /**
     追加するマーカーの種類を選択するためのアクションシートを表示する。
    */
    private func presentAdditionalMarkerActionSheet() {
        let actionSheet = UIAlertController.actionSheetWithTitle(title: "ActionSheetTitleDropMarker")
        actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetDropMarkerOnly", comment: "")) { _ in
            self.dropMarkerInCenterMap()
        }
// 吹き出しを画像化できない模様なので表示しない
//        actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetDropMarkerAndBalloon", comment: "")) { _ in
//            self.presentBalloonSubtitleAlert()
//        }
        actionSheet.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    /**
    地図の種類を切り替えるためのアクションシートを表示する。
    */
    private func presentMapTypeActionSheet() {
        let actionSheet = UIAlertController.actionSheetWithTitle(title: "ActionSheetTitleMapType")
        // 変更先の地図の種類のみ表示する
        if mapView.mapType == MKMapType.Standard {
            actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetMapTypeSatellite", comment: "")) { _ in
                self.mapView.mapType = MKMapType.Satellite
            }
        } else {
            actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetMapTypeStandard", comment: "")) { _ in
                self.mapView.mapType = MKMapType.Standard
            }
        }
        actionSheet.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func presentSettingsAlertController() {
        let alert = UIAlertController.settingsAlertWithMessage("AlertActionTitleSettings")
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
    吹き出しの内容を入力するためのアラートを表示する
    
    :param: targetView 入力後に吹き出しを表示する対象
    */
    private func presentBalloonSubtitleAlert() {
        let alert = UIAlertController.alertWithTitle(title: "AnnotationSubtitleTitle")
        alert.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        alert.addDefaultAction(title: NSLocalizedString("AlertActionOK", comment: "")) { action in
            // 入力が確定したらピンを落とす
            if let textField = alert.textFields?.first as? UITextField {
                if textField.text.isEmpty {
                    return
                }
                self.dropMarkerInCenterMap(annotationSubtitle: textField.text)
            }
        }
        
        alert.addTextFieldWithConfigurationHandler() { textField in
            textField.returnKeyType = .Done
            textField.selectAll(self)
            textField.placeholder = NSLocalizedString("AnnotationSubtitlePlaceholder", comment: "")
            textField.delegate = self
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextField Delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text as NSString
        text = text.stringByReplacingCharactersInRange(range, withString: string)
        // 最大25文字で制限
        return text.length <= kMaxAlertSubtitleLength
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return !textField.text.isEmpty
    }
}

// MARK: - MKMapView Delegate
extension MapViewController: MKMapViewDelegate, PhotosAlbumDelegate {
    
    /**
    MapViewの初期設定を行う
    */
    func setupMapView() {
        mapView.delegate = self
        snapshotter = Snapshotter(target: mapView, delegate: self)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        mapCenterCoordinate = mapView.region.center
        
        NSLog("\(mapView.region.center.latitude), \(mapView.region.center.longitude)")
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        // ピンは一個だけなので再利用できる場合は再利用する
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(kAnnotationId) as? MKPinAnnotationView
        if let recycledView = annotationView {
            recycledView.annotation = annotation
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationId)
        }
        
        // アノテーションのサブタイトルが入力されている場合は表示する
        if annotation.subtitle != nil {
            annotationView?.canShowCallout = true
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        if views.isEmpty {
            return
        }
        
        // サブタイトルが入力されている場合は表示する
        let annotationView = views.first as! MKAnnotationView
        if let annotation = annotationView.annotation as? Annotation {
            if annotation.hasSubtitle {
                mapView.selectAnnotation(annotationView.annotation, animated: false)
            }
            snapshotMapView(dropedAnnotation: annotation)
        }
    }
    
    private func dropMarkerInCenterMap(annotationSubtitle: String? = nil) {
        let annotation = Annotation(coordinate: mapCenterCoordinate, subtitle: annotationSubtitle)
        mapView.addAnnotation(annotation)
    }
    
    private func snapshotMapView(#dropedAnnotation: MKAnnotation) {
        SVProgressHUD.showWithStatus(NSLocalizedString("HUDSavedSnapshotProgress", comment: ""))
        
        // TODO: 遅延入れたほうがいいかも
        snapshotter.start(dropedAnnotation)
    }
    
    // MARK: Photos Album Delegate
    
    func savedPhotosAlbumError(error: NSError?, droppedAnnotation annotation: MKAnnotation) {
        var msg: String
        if error == nil {
            msg = NSLocalizedString("HUDSavedSnapshotSuccess", comment: "")
        } else {
            msg = NSLocalizedString("HUDSavedSnapshotFailed", comment: "")
        }
        SVProgressHUD.showSuccessWithStatus(msg)
        
        mapView.removeAnnotation(annotation)
    }
}

// MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    
    /**
    LocationManagerの初期設定を行う
    */
    func setupLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = 5.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations[0] as? CLLocation {
            // 初回起動時のみズームしながら現在位置へ地図を移動させる
            if currentLocation == nil {
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location.coordinate, span)
                mapView.setRegion(region, animated: true)
            }
            currentLocation = location
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
            case .Restricted, .Denied:
                presentSettingsAlertController()
            case .AuthorizedWhenInUse:
                startUpdatingLocation()
            default:
                break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)")
    }
    
    private func moveCurrentLocation() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // 既に許可が得られている場合は現在位置を取得
        if let location = currentLocation {
            mapView.setCenterCoordinate(location.coordinate, animated: true)
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        //locationUpdating = true
    }
}

// MARK: - Helper
extension MapViewController {
    
}