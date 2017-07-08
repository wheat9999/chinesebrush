//
//  CustomCamera.h
//  CameraTapper
//
//  Created by Jeffrey Berthiaume on 3/9/10.
//  Copyright 2010 pushplay.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CustomCamera : UIImagePickerController
{
    UIView* cameraOverlayView;
}

@property(nonatomic,copy)NSString* descHint;
@end
