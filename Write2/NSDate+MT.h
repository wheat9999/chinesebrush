//
//  NSDate+MT.h
//  microtask
//
//  Created by zhjb on 14-1-8.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

///日期扩展类
@interface NSDate (MT)

///转成标准日期字符串
-(NSString*)toStandardYYYYMMDD;

///转成时分秒全格式字符串
-(NSString*)toStandardful;

///转成时分秒文件名格式
-(NSString*)toFielName;

///获得日期的数字形式
-(int)toIntFormate;


@end
