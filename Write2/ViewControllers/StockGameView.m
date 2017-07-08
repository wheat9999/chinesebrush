//
//  StockGameView.m
//  Write2
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import "StockGameView.h"
#import "StockGame.h"
#import "KLine.h"
#import "StockGameController.h"

#define KLINENUM 30
#define LEST 3

#define ENTY 0.7

@implementation StockGameView
@synthesize stockGame = _stockGame;
@synthesize showStockName = _showStockName;
@synthesize parCtr= _parCtr;

-(void)setStockGame:(StockGame *)stockGame
{
    _stockGame = stockGame;
    index =rand()%([stockGame.quoteList count] - KLINENUM - LEST);
    
    [self refresh];
    
}

-(void)initMyFrame
{
    divY0 = 20;
    height0 = 240;
    divY1 = 280;
    height1 = 80;
    
    if ([UIScreen mainScreen].bounds.size.height<500)
    {
        divY0 = 10;
        height0 = 190;
        divY1 = 210;
        height1 = 60;
    }
    
    divx = 40;
    divxEnd = 310;
    
    colorPositvie = [UIColor colorWithRed:227/255.0 green:0/255.0 blue:0/255.0 alpha:1];
    
    colorNegative =  [UIColor colorWithRed:0/255.0 green:111/255.0 blue:5/255.0 alpha:1];
}


-(void)refresh
{
   
    [self initMyFrame];
    max_low = 99999999;
    max_high = 0;
    
    max_vol = 0;
    min_vol = 999999999;
    for (int i = index; i<=index+KLINENUM-1; i++)
    {
        KLine* kline = [_stockGame.quoteList objectAtIndex:i];
        
        max_low = MIN(max_low, kline.low);
        max_high = MAX(max_high, kline.high);
        
        max_vol = MAX(max_vol, kline.vol);
        min_vol = MIN(min_vol, kline.vol);
    }
    
    
    int distance = max_high -max_low;
    
    high_graphic = max_high+distance/14.0;
    low_graphic = MAX(0,max_low-distance/14.0);
    [self setNeedsDisplay];
    
    
    KLine* kline = [_stockGame.quoteList objectAtIndex:index+KLINENUM-1];
    
    KLine* lastKline = [_stockGame.quoteList objectAtIndex:index+KLINENUM-2];
    
    [_parCtr updateMyViewWithKLine:kline andLastKLine:lastKline];
    
}
-(BOOL)move
{
    index++;
    
    
    [self refresh];
    
    if ((index+KLINENUM-1) == [_stockGame.quoteList count]-1)
    {
        return NO;
    }
    return YES;
    //return [_stockGame.quoteList objectAtIndex:index+KLINENUM-1];
    
}

-(float)getRate
{
    int lastIndex = index +KLINENUM-1;
    KLine* klineLast0 = [_stockGame.quoteList objectAtIndex:lastIndex];
    KLine* klineLast1 = [_stockGame.quoteList objectAtIndex:lastIndex-1];
    float rate = (klineLast0.close-klineLast1.close)/(float)klineLast1.close;
    
    return rate;
    
}



-(void)drawTopHint
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor (context, 0.6, 0.3, 0.5, 1);
    UIFont  *font = [UIFont boldSystemFontOfSize:15.0];
    
    int lastIndex = index +KLINENUM-1;
    KLine* klineLast0 = [_stockGame.quoteList objectAtIndex:lastIndex];
    KLine* klineLast1 = [_stockGame.quoteList objectAtIndex:lastIndex-1];
    
    
    NSString* close = [NSString stringWithFormat:@"%.2f",klineLast0.close/100.0];
    
    NSString* prefix = klineLast0.close>klineLast1.close?@"+":@"";
    NSString* rate = [NSString stringWithFormat:@"%@%.2f%%",prefix,(klineLast0.close-klineLast1.close)*100/(float)klineLast1.close];
    
    NSString* high = [NSString stringWithFormat:@"%.2f",klineLast0.high/100.0];
    NSString* low = [NSString stringWithFormat:@"%.2f",klineLast0.low/100.0];
    NSString* open = [NSString stringWithFormat:@"%.2f",klineLast0.open/100.0];
    
    NSString* topHint = [NSString stringWithFormat:@"%@  %@ 高 %@ 低 %@ 开 %@",close,rate,high,low,open];
    
    if (_showStockName)
    {
        _showStockName = NO;
        topHint = [NSString stringWithFormat:@"    %@   【%@】",_stockGame.code,_stockGame.name];
    }
    [topHint drawInRect:CGRectMake(5, 10, 640, 20) withFont:font];
    
}

-(void)drawBounds
{
    int dis = high_graphic - low_graphic;
    float price0 = low_graphic/100.0;
    float price1 = (low_graphic+dis/4.0)/100.0;
    float price2 = (low_graphic+dis*2/4.0)/100.0;
    float price3 = (low_graphic+dis*3/4.0)/100.0;
    float price4 = high_graphic/100.0;
    
    
    NSString* str0 = [NSString stringWithFormat:@"%.2f",price0];
    NSString* str1 = [NSString stringWithFormat:@"%.2f",price1];
    NSString* str2 = [NSString stringWithFormat:@"%.2f",price2];
    NSString* str3 = [NSString stringWithFormat:@"%.2f",price3];
    NSString* str4 = [NSString stringWithFormat:@"%.2f",price4];
    
    
    NSString* strVol = [NSString stringWithFormat:@"%.2f",max_vol/100.0];
    
    NSString* strVolHalf = [NSString stringWithFormat:@"%.2f",max_vol/200.0];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor (context, 0.5, 0.5, 0.5, 0.5);
    float fontSize = 10.0;
    UIFont  *font = [UIFont boldSystemFontOfSize:fontSize];
    
    float wordX = 8;
    [str0 drawInRect:CGRectMake(wordX, divY0+height0-fontSize, 40, 40) withFont:font];
    [str1 drawInRect:CGRectMake(wordX, divY0+(height0*3/4.0)-fontSize/2, 40, 40) withFont:font];
    [str2 drawInRect:CGRectMake(wordX, divY0+(height0*2/4.0)-fontSize/2, 40, 40) withFont:font];
    [str3 drawInRect:CGRectMake(wordX, divY0+(height0/4.0)-fontSize/2, 40, 40) withFont:font];
    [str4 drawInRect:CGRectMake(wordX, divY0, 40, 40) withFont:font];
    
    [strVol drawInRect:CGRectMake(wordX, divY1, 40, 40) withFont:font];
    
    [strVolHalf drawInRect:CGRectMake(wordX, divY1+height1/2-fontSize/2, 40, 40) withFont:font];
    
    
    
    [[UIColor blackColor] set];
    //获得当前图形上下文
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(currentContext,0.5);
    //设置开始点位置
    CGContextMoveToPoint(currentContext,divx, divY0);
    //设置终点
    CGContextAddLineToPoint(currentContext,divxEnd,divY0);
    //设置另一个终点
    
     CGContextAddLineToPoint(currentContext,divxEnd,divY0+height0);
    
    CGContextAddLineToPoint(currentContext,divx,divY0+height0);
    
    CGContextAddLineToPoint(currentContext,divx,divY0);
    
    CGContextMoveToPoint(currentContext, divx, divY1);
    CGContextAddLineToPoint(currentContext, divxEnd, divY1);
    CGContextAddLineToPoint(currentContext, divxEnd, divY1+height1);
    CGContextAddLineToPoint(currentContext, divx, divY1+height1);
    CGContextAddLineToPoint(currentContext, divx, divY1);
    
    //画线
    CGContextStrokePath(currentContext);
    
    CGFloat lengths[] = {2,1};//设置虚线
    CGContextSetLineDash(currentContext, 0, lengths, 2);
    
    CGContextMoveToPoint(currentContext, divx, divY0+height0/4);
    
    CGContextAddLineToPoint(currentContext, divxEnd, divY0+height0/4);
    
    CGContextMoveToPoint(currentContext, divx, divY0+height0*2/4);
    
    CGContextAddLineToPoint(currentContext, divxEnd, divY0+height0*2/4);
    
    CGContextMoveToPoint(currentContext, divx, divY0+height0*3/4);
    
    CGContextAddLineToPoint(currentContext, divxEnd, divY0+height0*3/4);
    
    CGContextMoveToPoint(currentContext, divx, divY1+height1/2);
    CGContextAddLineToPoint(currentContext, divxEnd, divY1+height1/2);
    
    
    //画线
    CGContextStrokePath(currentContext);
    
    
    
    
    
    
}



-(void)drawKLineVol
{
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    float divItem = (divxEnd - divx)/KLINENUM;
    
    float widthK = divItem* ENTY;
    
    float widthBlank = divItem*(1-ENTY);
    
    float kDivx = divx;
    
    [[UIColor redColor] set];
    CGContextSetLineDash(currentContext, 0, nil, 0);
    
    int kDis = (high_graphic -low_graphic);
    
    KLine* lastK = nil;
    for (int i = index; i<index+KLINENUM; i++)
    {
        BOOL fillVol = NO;
        BOOL fillK = NO;
        
        KLine* kline = [_stockGame.quoteList objectAtIndex:i];
        
        //draw vol
        if (kline.close>=lastK.close)
        {
            [colorPositvie set];
        }
        else
        {
            [colorNegative set];
            fillVol = YES;
        }
        float volHeight = height1* kline.vol /max_vol;
        
        CGContextMoveToPoint(currentContext, kDivx, divY1+height1);
        
        CGContextAddLineToPoint(currentContext, kDivx, divY1+height1-volHeight);
        
        CGContextAddLineToPoint(currentContext, kDivx+widthK, divY1+height1-volHeight);
        
        CGContextAddLineToPoint(currentContext, kDivx+widthK, divY1+height1);
        
        if (fillVol)
        {
            CGRect rectangle = CGRectMake(kDivx, divY1+height1-volHeight,widthK,
                                          volHeight);
            
            [colorNegative
             setFill];
            CGContextFillRect(currentContext, rectangle);
        }
        
        //drawKline
        CGContextStrokePath(currentContext);
        
        if (kline.close>=kline.open) {
            [colorPositvie set];
        }
        else
        {
            [colorNegative set];
            fillK = YES;
        }
        
        float kHigh = divY0+height0 - (kline.high- low_graphic)*height0/kDis;
        float kLow = divY0+height0 - (kline.low- low_graphic)*height0/kDis;
        float kOpen = divY0+height0 - (kline.open- low_graphic)*height0/kDis;
        float kClose = divY0+height0 - (kline.close- low_graphic)*height0/kDis;
        
        float kUp = MIN(kOpen, kClose);
        float kDown = MAX(kOpen, kClose);
        
        
        CGContextMoveToPoint(currentContext, kDivx+widthK/2, kHigh);
        CGContextAddLineToPoint(currentContext, kDivx+widthK/2, kUp);
        
        CGContextMoveToPoint(currentContext, kDivx+widthK/2, kLow);
        CGContextAddLineToPoint(currentContext, kDivx+widthK/2, kDown);
        
        CGContextMoveToPoint(currentContext, kDivx, kUp);
        CGContextAddLineToPoint(currentContext, kDivx+widthK, kUp);
        CGContextAddLineToPoint(currentContext, kDivx+widthK, kDown);
        CGContextAddLineToPoint(currentContext, kDivx, kDown);
        CGContextAddLineToPoint(currentContext, kDivx, kUp);
        
        CGContextStrokePath(currentContext);
        
        
        if (fillK) {
            CGRect rectangle = CGRectMake(kDivx, kUp,widthK,
            (kDown-kUp));
            
            [colorNegative
             setFill];
            CGContextFillRect(currentContext, rectangle);
            
        }
        
        
        
        
        kDivx += divItem;
        
        lastK = kline;
        
        
    }
    
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //[self drawTopHint];
    [self drawBounds];
    if (_stockGame == nil) {
        return;
    }
    [self drawKLineVol];
    
    
}


@end
