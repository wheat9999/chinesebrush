//
//  Env.swift
//  FF
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class Env: NSObject
{
    var _records:Array<Record>?
    var _account:String?
    var _accuray:Double?
    var _curDate:String?
    var _read:String?
    
    static let sharedInstance = Env()
    
    private override init() {
        _records = Array();
        
        if let storeAccount =   NSUserDefaults.standardUserDefaults().valueForKey("account")
        {
            _account = storeAccount as? String
        }
        else
        {
            _account = "1"
        }
        
    
        if let storeAccuracy = NSUserDefaults.standardUserDefaults().valueForKey("accuray")
        {
            _accuray = storeAccuracy as? Double
        }
        else
        {
            _accuray = 50
        }
        
        if let storeRead = NSUserDefaults.standardUserDefaults().valueForKey("read")
        {
            _read = storeRead as? String
        }
        else
        {
            _read = "0"
        }
        
        
        _curDate = DateUtil.getCurrentDay()
    }
    
    func setTodayRecord(recods:Array<Record>)
    {
        
        _records = recods
    }
    
    func addRecord(record:Record)
    {
        var needAdd = false;
        if _records?.count == 0
        {
            needAdd = true
        }
        else
        {
            let lastRecord = _records![(_records?.count)!-1]
            let dis = Util.getDisWithGps1(record, record2: lastRecord)
            
            if dis < _accuray {
                print("too near!")
            }
            else
            {
                print("dis is \(dis)")
                needAdd = true
               
            }
        }
        
        
        if needAdd == true && _read == "0" {
            record.date = DateUtil.getCurrentDay()
            record.time = DateUtil.getCurrentTime()
            _records?.append(record)
            WebUtil.addRecord(record)
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("LOC-NEW", object: nil)
                    print($0)
            }
        }
        
    }
}
