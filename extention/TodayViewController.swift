//
//  TodayViewController.swift
//  extention
//
//  Created by kumagai on 2015/07/28.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        blurEffectView.layer.cornerRadius = 5
        blurEffectView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: NCWidget Providing
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(.NoData)
    }
    
    // MARK: Actions
    
    /**
    ココマップのアプリケーションを起動する
    */
    @IBAction func onLaunchApplication(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "kokomap://")!, completionHandler: nil)
    }
}
