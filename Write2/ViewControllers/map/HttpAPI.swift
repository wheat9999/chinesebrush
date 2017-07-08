//
//  HttpAPI.swift
//  FF
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duoying. All rights reserved.
//

import Foundation

class HTTPAPI: NSObject,NSURLConnectionDelegate,NSURLConnectionDataDelegate {
    
    var _callback:((String!)->Void)?
    var _resultData:NSMutableData?
    var _connect:NSURLConnection?
    
    
    func paramEncode(data:Dictionary<String,String>)->String
    {
        var result = "";
        for(key,value) in data
        {
            result += key+"="+value+"&"
            
        }
        
        if(result.characters.count>0)
        {
           
            result = result.substringToIndex(result.endIndex.advancedBy(-1));
        }
        
        return result
    }
    
    func getRemoteData(url:String,data:Dictionary<String,String>,callback:(String!)->Void)
    {
        
        _callback = callback
        
        
        
        let query = "?"+self.paramEncode(data);
        let fullUrl = url + query;
        print("############\(fullUrl)#################")
        let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!);
        request.timeoutInterval = 30;
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        _resultData = NSMutableData()
       
        _connect =  NSURLConnection(request: request, delegate: self, startImmediately: false);
        _connect?.start();
       
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        _resultData?.appendData(data)
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        print("error")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        let rawString = String.init(data:_resultData!, encoding: NSUTF8StringEncoding)
        _callback!(rawString)
    }
    
    
}