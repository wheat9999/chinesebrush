//
//  CheckVersion.h
//  IknowingiOS
//
//  Created by iknowing_zhaoxu on 13-1-18.
//  Copyright (c) 2013年 上海海知信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#define APP_DownloadURL @"http://itunes.apple.com/app/id654877201"
#define APP_URL @"http://itunes.apple.com/lookup?id=654877201"
@interface CheckVersion : NSObject<NSXMLParserDelegate>{
    NSMutableArray*parserObjects;
    NSMutableDictionary*dataDict;
    NSString*m_strCurrentElement;
    NSMutableString*tempString;
    NSArray* des;
    NSMutableDictionary*dic;
}

@property(nonatomic,retain)  NSString *m_strCurrentElement;
@property(nonatomic,retain)  NSMutableString *tempString;

+(CheckVersion *) sharedController;
-(NSMutableDictionary *)requestVersionXML;
@end

