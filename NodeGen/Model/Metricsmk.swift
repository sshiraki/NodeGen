//
//  File.swift
//  bus20
//
//  Created by SUNAO SHIRAKI on 2018/10/05.
//  Copyright © 2018年 SATOSHI NAKAJIMA. All rights reserved.
//

import MapKit

// for MapKit
struct Metricsmk {
    
    //static let centerx : CLLocationDegrees = 34.097970
    static let centery : CLLocationDegrees = 33.5151439
    //static let centery : CLLocationDegrees = 132.080475
    static let centerx : CLLocationDegrees = 133.5252225
    static let defaultspan : CLLocationDegrees = 0.03
    static let maproadwidth : CGFloat = 4.0
    static let maproadcolornormal : UIColor = UIColor(red: (255/255.0), green: (128/255.0), blue: (0/255.0), alpha: 1.0)
    static let maproadcolorselect : UIColor = UIColor(red: (255/255.0), green: (0/255.0), blue: (128/255.0), alpha: 1.0)
    static var maproadcolor = maproadcolornormal
    static var image : UIImage!

}
