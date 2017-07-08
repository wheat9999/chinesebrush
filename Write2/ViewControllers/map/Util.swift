//
//  Util.swift
//  FF
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class Util{
    
    
    static func parse(rawString:String)->Array<Record>
    {
        let data = rawString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let jsonArr = try! NSJSONSerialization.JSONObjectWithData(data!,
            options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String,AnyObject>
        var recodesArray:Array<Record> = Array()
        
        let dataArray = jsonArr["data"] as! Array<Dictionary<String,String>>
        for item  in dataArray
        {
            let t = Record()
            t.date = item["date"]
            t.time = item["time"]
            t.x = (item["x"]! as NSString).doubleValue
            t.y = (item["y"]! as NSString).doubleValue
            
            recodesArray.append(t)
            
        }
        
        return recodesArray
        
    }
    
    static func getDisWithGps1(record1:Record,record2:Record)->Double
    {
        let R = 6370996.81;
        let  pi = 3.1415926;
        
        let lng1 = record1.x;
        let lng2 = record2.x;
        let lat1 = record1.y;
        let lat2 = record2.y;
        
        let tmp1 = cos(lat1!*pi/180)
        
        let tmp2 = cos(lat2!*pi/180)
        
        let tmp3 = cos(lng1!*pi/180-lng2!*pi/180)
        
        let tmp4 = sin(lat1!*pi/180)
        
        let tmp5 = sin(lat2!*pi/180)
        
        
        let ar = tmp1*tmp2*tmp3+tmp4*tmp5
        
        let dis = R*acos(ar)
        
        return dis;
    }
    
}