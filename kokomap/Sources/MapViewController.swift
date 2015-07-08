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

/**
 * 地図機能を提供するためのビューコントローラ
 *
 * @author kumagai
 */
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
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
extension MapViewController {
 
    /**
     追加するマーカーの種類を選択するためのアクションシートを表示する。
    */
    func presentAdditionalMarkerActionSheet() {
        let actionSheet = makeActionSheet(title: "ActionSheetTitleDropMarker")
        actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetDropMarkerOnly", comment: "")) { _ in
            self.dropMarkerInCenterMap()
        }
        actionSheet.addDefaultAction(title: NSLocalizedString("ActionSheetDropMarkerAndBalloon", comment: "")) { _ in
        }
        actionSheet.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    /**
    地図の種類を切り替えるためのアクションシートを表示する。
    */
    func presentMapTypeActionSheet() {
        let actionSheet = makeActionSheet(title: "ActionSheetTitleMapType")
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
}

// MARK: - MKMapView Delegate
extension MapViewController: MKMapViewDelegate {
    
    /**
    MapViewの初期設定を行う
    */
    func setupMapView() {
        mapView.delegate = self
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
            annotationView!.canShowCallout = true
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
    }
    
    private func dropMarkerInCenterMap(annotationSubtitle: String? = nil) {
        let annotation = Annotation(coordinate: mapCenterCoordinate)
        mapView.addAnnotation(annotation)
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
                presentSettingsAlertWithMessage(NSLocalizedString("AlertMessageDisabledLocationService", comment: ""))
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
    
    // MARK: Extension Methods
    
    /**
    設定画面を開くためのアラートを表示する
    
    :param: message アラートのメッセージ
    */
    private func presentSettingsAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)        
        alert.addCancelAction(title: NSLocalizedString("AlertActionCancel", comment: ""), handler: nil)
        alert.addDefaultAction(title: NSLocalizedString("AlertActionTitleSettings", comment: "")) { action in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func makeActionSheet(#title: String) -> UIAlertController {
        return UIAlertController(title: NSLocalizedString(title, comment: ""),
                               message: nil,
                        preferredStyle: .ActionSheet)
    }
}