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
    
    
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
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
        shareSnapshot()
    }
}

// MARK: - Actions
extension PreviewViewController: SnapshotWriteDelegate {
    
    /**
    スナップショットをアルバムに保存する
    */
    private func saveSnapshot() {
        lockViews()
        
        SVProgressHUD.showWithStatus(NSLocalizedString("HUDSavingSnapshotProgress", comment: ""))
        snapshotWriter.writeImage(snapshotImage)
    }
    
    /**
    スナップショットを他アプリに教諭する
    */
    private func shareSnapshot() {
        let images: [UIImage] = [snapshotImage]
        let activityController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
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

// MARK: - Helper
extension PreviewViewController {
    
    private func lockViews() {
        for button in [saveBarButton, shareBarButton, deleteBarButton] {
            button.enabled = false
        }
    }
}