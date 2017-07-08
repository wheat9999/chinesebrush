//
//  WebUtil.swift
//  FF
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class WebUtil: NSObject {
    static func getDayRecord(date:String,index:String,callback:(String!)->Void)
    {
        let httpApi = HTTPAPI();
        let url = "http://115.29.237.213/FF/index.php"
        httpApi.getRemoteData(url,
            data: ["r":"record/search",
            "account":Env.sharedInstance._account!,
            "date":date,
                "dateIndex":index],callback: callback)
        
    }
    
    static func addRecord(record:Record,callback:(String!)->Void)
    {
        let httpApi = HTTPAPI();
        let url = "http://115.29.237.213/FF/index.php"
        httpApi.getRemoteData(url,
            data: ["r":"record/add",
                "account":Env.sharedInstance._account!,
                "x":"\(record.x!)",
                "y":"\(record.y!)"],callback: callback)
    }
}
