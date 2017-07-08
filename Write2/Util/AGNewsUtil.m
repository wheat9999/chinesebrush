//
//  AGNewsUtil.m
//  Write2
//
//  Created by zhjb on 14-6-23.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGNewsUtil.h"

#define IS_CH_SYMBOL(chr) ((int)(chr)>127 || (chr>='0' && chr <= '9'))
#define RESTWORD 5

@implementation AGNewsUtil


+ (int)hasChRest:(NSString*)content andIndex:(int)index
{
    int hasChIndex = -1;
    for (int i = 1; i<RESTWORD &&  (index+i)<content.length; i++)
    {
        unichar ch = [content characterAtIndex:index+i];
        
        if(IS_CH_SYMBOL(ch))
        {
            hasChIndex = i;
            break;
        }
    }
    
    return hasChIndex;
}


+(NSString*)getAvailableNews:(NSString*)content
{
    content =  [content stringByReplacingOccurrencesOfString:@"<(S*?)[^>]*>.*?|<.*?/>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, content.length)];
    
    NSString* maxString = @"";
    
    BOOL tagStart = NO;
    
    int startIndex = 0;
    
    for (int i = 0; i<content.length;i++)
    {
        
        unichar ch = [content characterAtIndex:i];
        
        if (IS_CH_SYMBOL(ch))
        {
            if (!tagStart)
            {
                tagStart = YES;
                startIndex = i;
            }
            
        }
        else
        {
            if (!tagStart)
            {
                continue;
            }
            int index = [self hasChRest:content andIndex:i];
            
            if (index>0)
            {
                i += index;
            }
            else
            {
                tagStart = NO;
                
                int length = i - startIndex;
                
                
                if (length > maxString.length)
                {
                    maxString = [content substringWithRange:NSMakeRange(startIndex, length)];
                }
                
                
                
                
            }
            
        }
        
        
    }
    
    
    return maxString;
    
//    NSString *jsString = [NSString stringWithFormat:@"<html> \n"
//                          "<head> \n"
//                          "<style type=\"text/css\"> \n"
//                          "body {font-size: %f; font-family: \"%@\";}\n"
//                          "</style> \n"
//                          "</head> \n"
//                          "<body>%@</body> \n"
//                          "</html>", 58.0, @"Serif", maxString];
//    
//    
//    return jsString;
}

@end
