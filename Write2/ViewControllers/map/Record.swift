//
//  Record.swift
//  FF
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class Record: NSObject
{
    var x:CLLocationDegrees?
    var y:CLLocationDegrees?
    var date:String?
    var time:String?
    
    override init() {
        x = 0
        y = 0
    }
    init(_x:CLLocationDegrees,_y:CLLocationDegrees) {
        x = _x
        y = _y
    }
}
