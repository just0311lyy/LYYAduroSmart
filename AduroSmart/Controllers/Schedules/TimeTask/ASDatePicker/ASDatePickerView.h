//
//  ASDatePickerView.h
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    
    // 开始日期
    DateTypeOfStart = 0,
    
    // 结束日期
    DateTypeOfEnd,
    
}DateType;

@protocol ASDatePickerViewDelegate <NSObject>

/**
 *  选择日期确定后的代理事件
 *
 *  @param date 日期
 *  @param type 时间选择器状态
 */
- (void)getSelectDate:(NSString *)date type:(DateType)type;

@end



@interface ASDatePickerView : UIView

//+ (ASDatePickerView *)instanceDatePickerView;

@property (nonatomic, strong) UIDatePicker *datePickerView;

@property (nonatomic, weak) id<ASDatePickerViewDelegate> delegate;

@property (nonatomic, assign) DateType type;



@end
