//
//  DateUtil.swift
//  FF
//
//  Created by mac on 16/4/9.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class DateUtil
{
    static func getDateString(date:NSDate)->String{
        
        let f:NSDateFormatter = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        
        //用[NSDate date]可以获取系统当前时间
        let strDate = f.stringFromDate(date)
        
        return strDate
    }
    
    static func getCurrentDay()->String
    {
        let curDate:NSDate =  NSDate()
        return self.getDateString(curDate)
    }
    
    static func getCurrentTime()->String{
        let curDate:NSDate =  NSDate()
        let f:NSDateFormatter = NSDateFormatter()
        f.dateFormat = "HH:mm:ss"
        
        //用[NSDate date]可以获取系统当前时间
        let strTime = f.stringFromDate(curDate)
        
        return strTime
    }
}

