//
//  ASBatteryLevelView.m
//  AduroSmart
//
//  Created by MacBook on 16/8/31.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBatteryLevelView.h"

@implementation ASBatteryLevelView

- (void)drawRect:(CGRect)rect {
    UIColor *aColor;
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //绘画环境
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*画矩形*/
    CGContextSetLineWidth(context, 2.0);//线的宽度
    aColor = LOGO_COLOR;
    CGContextSetStrokeColorWithColor(context, aColor.CGColor);//线框颜色
    CGContextStrokeRect(context,CGRectMake(0, 0, width - 10, height));//画方框
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextFillRect(context,CGRectMake(3, 3, (width - 10 - 6) * _currentNum / 200, height - 6)); //填充框
    
    
//    /*画矩形*/
//    //矩形，并填弃颜色
//    CGContextSetLineWidth(context, 2.0);//线的宽度
////    aColor = LOGO_COLOR;
////    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
//    aColor = [UIColor blackColor];
//    CGContextSetStrokeColorWithColor(context, aColor.CGColor);//线框颜色
//    CGContextAddRect(context,CGRectMake(0, 0, width-4, height));//画方框
//    CGContextDrawPath(context, kCGPathEOFillStroke);//绘画路径
//    
//    aColor = LOGO_COLOR;
//    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
//    CGContextAddRect(context,CGRectMake(3, 3, width-4-3, height-6));//画方框
//    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    
    
    
    
    CGContextMoveToPoint(context, width-10, height/2);
    
    CGContextAddLineToPoint(context, width-5, height/2);

    CGContextSetLineWidth(context, 7);

    CGContextStrokePath(context);
    
//    CGRect frame = CGRectMake(10, 10, 40, 20);
//    CGContextSetStrokeColorWithColor(bgContextRef, LOGO_COLOR.CGColor);
//    CGContextAddRect(bgContextRef, frame); //画方框
//    
//    CGContextSetLineWidth(bgContextRef, 1);
//    
////    [commonBgColor setStroke];
//    
//    CGContextStrokePath(bgContextRef);
//    
//    
//    
//    CGContextMoveToPoint(bgContextRef, 50, 20);
//    
//    CGContextAddLineToPoint(bgContextRef, 54, 20);
//    
//    CGContextSetLineWidth(bgContextRef, 8);
//    
//    CGContextStrokePath(bgContextRef);
//    
//    
//    
//    CGContextMoveToPoint(bgContextRef, 10, 20);
//    
//    CGContextAddLineToPoint(bgContextRef, 10+_currentNum*40/100, 20);
//    
//    CGContextSetLineWidth(bgContextRef, 20);
//    
//    CGContextStrokePath(bgContextRef);
    
}

@end
