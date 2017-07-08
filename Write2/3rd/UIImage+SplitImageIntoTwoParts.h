//
//  UIImage+SplitImageIntoTwoParts.h
//  TapRepublic
//
//  Created by Terry Lin on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SplitImageIntoTwoParts)
+ (NSArray*)splitImageIntoTwoParts:(UIImage*)image;

+(UIImage*)getImageWithName:(NSString*)filename;

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;
@end
