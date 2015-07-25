//
//  Snapshotter.swift
//  kokomap
//
//  Created by kumagai on 2015/07/18.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import Foundation
import MapKit

/**
 MKMapViewのスナップショットを生成する。
*/
class Snapshotter: NSObject {
    
    private let mapView: MKMapView
    private let delegate: PhotosAlbumDelegate
    
    // 地図に追加したピン(削除するときに必要）
    private var annotation: MKAnnotation!
    
    // MARK: Initializer
    
    /**
    新しいインスタンスを作成する
    
    :param: mapView スナップショット対象の地図
    */
    init(target mapView: MKMapView, delegate: PhotosAlbumDelegate) {
        self.mapView = mapView
        self.delegate = delegate
    }
    
    // MARK: Public Methods
    
    /**
    地図のスナップショットを生成する
    
    :param: droppedAnnotation 地図に追加したピン
    */
    func start(droppedAnnotation: MKAnnotation) {
        annotation = droppedAnnotation
        
        let snapshotter = MKMapSnapshotter(options: makeSnapshotOptions())
        snapshotter.startWithCompletionHandler { snapshot, error in
            // スナップショットの生成に失敗した場合
            if let snapshotError = error {
                NSLog("Snapshot Error: \(snapshotError.localizedDescription)")
                self.delegate.savedPhotosAlbumError(snapshotError, droppedAnnotation: self.annotation)
                return
            }
            
            let image = snapshot.image
            let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            
            image.drawAtPoint(CGPointMake(0, 0))
            
            for annotation in self.mapView.annotations as! [MKAnnotation] {
                var view = self.mapView.viewForAnnotation(annotation)
                var point = snapshot.pointForCoordinate(annotation.coordinate)
                if CGRectContainsPoint(imageRect, point) {
                    point.x -= view.bounds.size.width / 2.0
                    point.y -= view.bounds.size.height / 2.0
                    point.x += view.centerOffset.x
                    point.y += view.centerOffset.y
                    
                    view.image?.drawAtPoint(point)
                }
            }
            let mapImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let jpegImage = UIImage(data: UIImageJPEGRepresentation(mapImage.imageByCloppedSquareImage(), 85.0))
            UIImageWriteToSavedPhotosAlbum(jpegImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    // MARK: Private
    
    private func makeSnapshotOptions() -> MKMapSnapshotOptions {
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size = mapView.frame.size
        options.mapType = mapView.mapType
        options.scale = UIScreen.mainScreen().scale
        
        return options
    }
    
    // MARK: Saved Photos Album
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutablePointer<Void>) {
        if let savingError = error {
            NSLog("Snapshot saving error: \(savingError.localizedDescription)")
        }
        delegate.savedPhotosAlbumError(error, droppedAnnotation: annotation)
        annotation = nil
    }
}

/**
  アルバムに地図のスナップショットを保存した際に呼ばれる
*/
protocol PhotosAlbumDelegate {
    
    /**
    スナップショットをアルバムに保存した後呼ばれる処理
    
    :param: error エラー情報
    :param: droppedAnnotation 地図に追加したピン
    */
    func savedPhotosAlbumError(error: NSError?, droppedAnnotation annotation: MKAnnotation)
}