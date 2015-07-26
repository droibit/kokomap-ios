//
//  ImageWriter.swift
//  kokomap
//
//  Created by kumagai on 2015/07/26.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import Foundation

/**
 * スナップショットをアルバムに保存する
 */
class SnapshotWriter: NSObject {
    
    private let delegate: SnapshotWriteDelegate
    
    // MARK: Initializer
    
    /**
    新しいインスタンスを生成する
    
    :param: delegate アルバム保存後の処理のデリゲート
    */
    init(delegate: SnapshotWriteDelegate) {
        self.delegate = delegate
    }
    
    // MARK: Public
    
    /**
    アルバムにスナップショット保存する
    
    :param: image 保存対象のスナップショット
    */
    func writeImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // MARK: Private
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutablePointer<Void>) {
        if let savingError = error {
            NSLog("Snapshot saving error: \(savingError.localizedDescription)")
        }
        delegate.writedPhotoAlbumError(error)
    }
}

/**
 * アルバムにスナップショットが保存された時の処理を移譲する
 */
protocol SnapshotWriteDelegate {
    
    /**
    アルバムにスナップショットを保存した後呼ばれる処理
    
    :param: error エラー情報
    */
    func writedPhotoAlbumError(error: NSError?)
}
