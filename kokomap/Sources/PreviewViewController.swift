//
//  PreviewViewController.swift
//  kokomap
//
//  Created by kumagai on 2015/07/25.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import UIKit

/**
* 作成したスナップショット表示するためのビューコントローラ
*/
class PreviewViewController: UIViewController {
    
    var snapshotImage: UIImage!
    var snapshotWriter: SnapshotWriter!

    @IBOutlet weak var snapshotView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snapshotView.image = snapshotImage
        snapshotView.contentMode = .ScaleAspectFit
        
        snapshotWriter = SnapshotWriter(delegate: self)
    }
    
    /**
    スナップショットをアルバムに保存するときに呼ばれる処理
    */
    @IBAction func onSaveSnapshot(sender: AnyObject) {
        saveSnapshot()
    }
    
    
    @IBAction func onDeleteSnapshot(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onShareSnapshot(sender: AnyObject) {
    }
}

// MARk: - Actions
extension PreviewViewController: SnapshotWriteDelegate {
    
    private func saveSnapshot() {
        SVProgressHUD.showWithStatus(NSLocalizedString("HUDSavingSnapshotProgress", comment: ""))
        
        snapshotWriter.writeImage(snapshotImage)
    }
    
    // MARK: SnapshotWriteDelegate
    
    func writedPhotoAlbumError(error: NSError?) {
        dismissViewControllerAnimated(true) {
            if error == nil {
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("HUDSavedSnapshotSuccess", comment: ""))
            } else {
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("HUDSavedSnapshotFailed", comment: ""))
            }
        }
    }
}
