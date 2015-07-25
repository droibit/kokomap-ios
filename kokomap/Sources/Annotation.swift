//
//  Annotation.swift
//  kokomap
//
//  Created by kumagai on 2015/07/08.
//  Copyright (c) 2015年 droibit. All rights reserved.
//

import Foundation
import MapKit

/**
MKAnnotationプロトコルの実装。
タイトルは「ココ」（ローカライズ有）固定でサブタイトルはオプション。
*/
class Annotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    var hasSubtitle: Bool {
        return subtitle != nil
    }
    
    override var description: String {
        return title!
    }
    
    init(coordinate: CLLocationCoordinate2D, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title =  NSLocalizedString("AnnotationTitle", comment: "")
        self.subtitle = subtitle
    }
}