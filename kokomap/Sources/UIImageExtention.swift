//
//  UIImageExtention.swift
//  kokomap
//
//  Created by kumagai on 2015/07/19.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
    正方形に切り取った画像を生成する
    
    :returns: 正方形に切り取った新しいUIImage
    */
    func imageByCloppedSquareImage() -> UIImage {
        // 画像の実サイズから計算しないと縮小されてしまう
        let refWidth = CGFloat(CGImageGetWidth(self.CGImage))
        let refHeight = CGFloat(CGImageGetHeight(self.CGImage))
        
        let shortSide = min(refWidth, refHeight)
        let offset = abs(refWidth - refHeight)
        
        let point: CGPoint
        if refHeight > refWidth {
            point = CGPointMake(0, offset / 2.0)
        } else {
            point = CGPointMake(offset / 2.0, 0)
        }
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(point.x, point.y, shortSide, shortSide))
        return UIImage(CGImage: imageRef)!
    }
}