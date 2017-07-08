//
//  WriteView.h
//  Write
//
//  Created by zhangjb on 13-5-8.
//  Copyright (c) 2013年 zhangjb. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TAGBTNOK 1000

//每个字完成，都会收到一个wordcomplete的通知，dic里面的img对应的就是新产生的Imageview
#define NOTIWORDCOMPLETE @"wordcompelete"
#define NOTIIMAGE @"img"

#define NOTICURSOR @"nextcursor"
#define NOTICURSORX @"nextcursorX"
#define NOTICURSORY @"nextcursorY"


//横竖书写模式
typedef enum
{
    
    kWordHorizontal,
    kWordHorizontalReverse,
    kWordVertical,
    kWordVerticalReverse
    
}kWordArrange;

//书法模式，不同的模式，具有不同的速度模型和图像
typedef enum
{
    kWordNormal,
    kWordStyle1,
    kWordStyle2,
    kWordStyle3,
    kWordStyle4
    
}kWordMode;

@interface WriteView : UIImageView

//起点字的位置,在父窗口的相对位置
@property(nonatomic,assign)CGPoint startPoint;


//字体的大小
@property(nonatomic,assign)CGSize wordSize;


//横写或者竖写模式
@property(nonatomic,assign)kWordArrange wordArrange;

//背景图片
@property(nonatomic,copy)NSString* bgName;

//纸张的宽度 水平写有效
@property(nonatomic,assign)float pageWidth;

//纸张的高度 垂直写有效
@property(nonatomic,assign)float pageHeight;

//字的间距
@property(nonatomic,assign)float wordBlank;

//字的行距
@property(nonatomic,assign)float lineBlank;

//字体的缩放 默认为100%
@property(nonatomic,assign)float percent;

//设置字体停留时间
@property(nonatomic,assign)float remainTime;

//设置书法模式
@property(nonatomic,assign)kWordMode wordMode;

//字体飞跃的动画时间
@property(nonatomic,assign)float animateTime;

//字体写入的位置
@property(nonatomic,assign)CGPoint wordPoint;

@property(nonatomic,assign)UIScrollView* outPannelView;

@property(nonatomic,assign)UIViewController* parentCtr;

//每行字的个数
@property(nonatomic,assign)int linenum;


+ (id)sharedWriteViewWith:(CGRect)frame;

-(void)insertBlank;

@end
