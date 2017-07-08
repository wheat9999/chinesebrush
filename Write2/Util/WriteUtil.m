//
//  WriteUtil.m
//  Write2
//
//  Created by zhjb on 14-6-30.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "WriteUtil.h"
#import "DeviceUtil.h"

@implementation WriteUtil

+(NSString*)getToken
{
    NSArray* tokenList = [[BaseDAO sharedInstance] getList:@"Config" andCondition:@{@"key":@"token"}];
    
    if ([tokenList count] == 0)
    {
        return [DeviceUtil getUUID];
    }
    else
    {
        return Store(@"token");
    }
}

+(void)setLabelColor:(UILabel*)lb
{
    if ([lb.text characterAtIndex:0] == '-')
    {
        lb.textColor = [UIColor greenColor];
    }
    else
    {
        lb.textColor = [UIColor redColor];
    }
    
}

@end
