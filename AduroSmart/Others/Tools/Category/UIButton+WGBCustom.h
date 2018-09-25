//
//  UIButton+WGBCustom.h
//  自定义Button
//
//  Created by Wangguibin on 16/4/11.
//  Copyright © 2016年 王贵彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (WGBCustom)


/*!
 *  @author  WGB  , 16-04-11 15:04:25
 *
 *  @brief 标题在上 图片在下
 *
 *  @param space 它们之间的间距
 */

/**  设置标题在图片上方  */
- (void)titleOverTheImageTopWithSpace:(CGFloat)space;

/*!
 *  @author  WGB  , 16-04-11 15:04:25
 *
 *  @brief  图片在上 标题在下
 *
 *  @param space 它们之间的间距
 */

- (void)titleBelowTheImageWithSpace:(CGFloat)space;

/*!
 *  @author  WGB  , 16-04-11 15:04:25
 *
 *  @brief  图片在左 标题在右 (系统默认的也是这种 这里提供设置间距的接口)
 *
 *  @param space 它们之间的间距
 */
- (void)imageOnTheTitleLeftWithSpace:(CGFloat)space;

/*!
 *  @author  WGB  , 16-04-11 15:04:25
 *
 *  @brief  标题在左    图片在右 
 *
 *  @param space 它们之间的间距
 */
- (void)imageOnTheTitleRightWithSpace:(CGFloat)space;




@end
