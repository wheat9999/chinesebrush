//
//  AGMainController.h
//  Write2
//
//  Created by zhjb on 14-6-5.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>



#import "WriteView.h"
#define DEFAULT_BRUSHPERCENT 0.6
#define DEFAULT_REMAINTTIME 1
#define DEFAULT_ANNIMATIONTIME 1
#define DEFAULT_ARRANGE 0
#define DEFAULT_LINENUM 7
#define DEFAULT_WORDHEIGHT 70
#define DEFAULT_WORDWIDTH 70
#define DEFAULT_WRITEHEIGHT 300
#define DEFAULT_WRITEWIDTH 300
#define DEFAULT_PANNELBG 4
#define DEFAULT_WRITEBG 3
#define DEFAULT_BRUSHMODE 1
#define DEFAULT_PAOMADENGSPEED 5

#define DEFAULT_BRUSHMODEAVAIL @"0,1,2,3,4"

#define DEFAULT_BUYNUMAVAIL 0

#define DEFAULT_DOWNLOADAVAIL 0

#define DEFAULT_EXAMHEIGHT 40


#define BRUSHWIDTH  @"brush_percent"
#define REMAINTIME @"remain_time"
#define ANNIMATIONTIME @"animation_time"

#define ARRANGE @"arrange_type"
#define LINENUM @"line_num"


#define WORDHEIGHT @"word_height"
#define WORDWIDTH @"word_width"
#define WRITEHEIGHT @"write_height"
#define WRITEWIDTH @"write_width"
#define PANNELBG @"pannel_bg"
#define WRITEBG @"write_bg"
#define BRUSHMODE @"brush_mode"
#define BRUSHMODEAVAIL @"brushmodeavailable"
#define PAOMADENGSPEED @"paomadeng_speed"
#define BUYNUMAVAIL @"buynumavail"
#define CHECKTIME @"checktime"
#define DOWNLOADAVAIL @"downloadavail"
#import <iAd/iAd.h>


@interface AGMainController : UIViewController<ADBannerViewDelegate>
{
    IBOutlet UIView* paomadengBgView;
    
    IBOutlet ADBannerView *adView;
    BOOL bannerIsVisible;
}


@property(nonatomic,retain)UIButton* btn;

@property(nonatomic,assign)BOOL exerciseState;


- (void)clearPannel;
- (void)savePannel;

- (UIImage*)getImage;

- (void)changeBrush:(float)percent;

- (void)changeRemainTime:(float)time;

- (void)changeAnimationTime:(float)time;

- (void)changeArrange:(kWordArrange)newArrange andNum:(int)num;

- (void)changeWordSize:(CGSize)newWordSize;

- (void)changeWriteSize:(CGSize)newWriteSize;

-(void)toSlidDown;

- (void)changePannelBg:(int)bgIndex;

- (void)changeWriteBg:(int)bgIndex;

- (void)changeWordMode:(int)wordMode;

- (void)changeExerciseMode;

-(void)setPaomadeng:(NSString*)content;

-(int)getWordNum;

@end
