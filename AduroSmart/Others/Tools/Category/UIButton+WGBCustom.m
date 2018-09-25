//
//  UIButton+WGBCustom.m
//  自定义Button
//
//  Created by Wangguibin on 16/4/11.
//  Copyright © 2016年 王贵彬. All rights reserved.
//
#import "UIButton+WGBCustom.h"

@implementation UIButton (WGBCustom)

/**  标题在上  */
- (void)titleOverTheImageTopWithSpace:(CGFloat)space
{
    [self judgeTheTitleInImageTop:YES space:space];
}

/**  标题在下  */
-(void)titleBelowTheImageWithSpace:(CGFloat)space
{
    [self judgeTheTitleInImageTop:NO space:space];
}

/**  判断标题是不是在上   */
- (void)judgeTheTitleInImageTop:(BOOL)isTop space:(float)space ;
{
    [self resetEdgeInsets];  //重置内边距
    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect contentRect = [self contentRectForBounds:self.bounds];
    CGSize titleSize = [self titleRectForContentRect:contentRect].size;
    CGSize imageSize = [self imageRectForContentRect:contentRect].size;

    float halfWidth = (titleSize.width + imageSize.width)/2;
    float halfHeight = (titleSize.height + imageSize.height)/2;

    float topInset = MIN(halfHeight, titleSize.height);
    float leftInset = (titleSize.width - imageSize.width)>0?(titleSize.width - imageSize.width)/2:0;
    float bottomInset = (titleSize.height - imageSize.height)>0?(titleSize.height - imageSize.height)/2:0;
    float rightInset = MIN(halfWidth, titleSize.width);

    if (isTop) {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(-titleSize.height-space, - halfWidth, imageSize.height+space, halfWidth)];
        [self setContentEdgeInsets:UIEdgeInsetsMake(topInset+space, leftInset, -bottomInset, -rightInset)];
        
    } else {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageSize.height+space, - halfWidth, -titleSize.height-space, halfWidth)];
        [self setContentEdgeInsets:UIEdgeInsetsMake(-bottomInset, leftInset, topInset+space, -rightInset)];
    }
}

/**  图片在左  系统默认的样式  只需提供修改内边距的接口*/
-(void)imageOnTheTitleLeftWithSpace:(CGFloat)space{
    [self resetEdgeInsets];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, space, 0, -space)];
    [self setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, space)];
}

/**  图片再右  */
- (void)imageOnTheTitleRightWithSpace:(CGFloat)space
{
    [self resetEdgeInsets];
    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect contentRect = [self contentRectForBounds:self.bounds];
    CGSize titleSize = [self titleRectForContentRect:contentRect].size;
    CGSize imageSize = [self imageRectForContentRect:contentRect].size;

    [self setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, space)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width, 0, imageSize.width)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width+space, 0, -titleSize.width - space)];
}

//重置内边距
- (void)resetEdgeInsets
{
    [self setContentEdgeInsets:UIEdgeInsetsZero];
    [self setImageEdgeInsets:UIEdgeInsetsZero];
    [self setTitleEdgeInsets:UIEdgeInsetsZero];
}


@end
