//
//  AGWebController.h
//  Write2
//
//  Created by zhjb on 14-6-23.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AGWebController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView* myWebView;
}

@property(nonatomic,copy)NSString* strUrl;

@end
