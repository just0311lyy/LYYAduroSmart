//
//  UIImage+ColorAtPixel.h
//  AduroSmart
//
//  Created by MacBook on 16/7/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorAtPixel)

- (UIColor *)colorAtPixel:(CGPoint)point;
- (NSArray *)RGBAtPixel:(CGPoint)point;

@end
