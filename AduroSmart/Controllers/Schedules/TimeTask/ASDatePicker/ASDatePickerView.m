//
//  ASDatePickerView.m
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDatePickerView.h"

@interface ASDatePickerView ()

@property (nonatomic, strong) NSString *selectDate;
@property (strong, nonatomic) UIButton *cannelBtn;
@property (strong, nonatomic) UIButton *sureBtn;
@property (strong, nonatomic) UIView *backgVIew;
@property (strong, nonatomic) UIButton *backGroundBtn;

@end

@implementation ASDatePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.datePickerView = [[UIDatePicker alloc] init];
        [self.backgVIew addSubview:self.datePickerView];
        
        self.backGroundBtn = [[UIButton alloc] init];
        [self addSubview:self.backGroundBtn];
        [self.sureBtn addTarget:self action:@selector(backGroundBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgVIew = [[UIView alloc] init];
        [self.backGroundBtn addSubview:self.backgVIew];
        
        
        self.cannelBtn = [[UIButton alloc] init];
        [self.backgVIew addSubview:self.cannelBtn];
        self.cannelBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        [self.cannelBtn addTarget:self action:@selector(removeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.sureBtn = [[UIButton alloc] init];
        [self.backgVIew addSubview:self.sureBtn];
        self.sureBtn.layer.borderColor = [[UIColor greenColor] CGColor];
        [self.sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //上划线
    self.backGroundBtn.frame = CGRectMake(0, 0, width, height);
    self.backgVIew.frame = CGRectMake(20, 150, width - 40, 300);
    self.backgVIew.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.datePickerView.frame = CGRectMake(0,10,self.backgVIew.frame.size.width,216);
    
    self.cannelBtn.frame = CGRectMake(20, self.backgVIew.frame.size.height + 10 + 14, (self.backgVIew.frame.size.width - 60)/2,40);
    
    self.sureBtn.frame = CGRectMake(20 + self.cannelBtn.frame.size.width + 20 , self.backgVIew.frame.size.height + 10 + 14, (self.backgVIew.frame.size.width - 60)/2, 40);
    
}

//+ (ASDatePickerView *)instanceDatePickerView
//{
//    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"ASDatePickerView" owner:nil options:nil];
//    return [nibView objectAtIndex:0];
//}

/**
 *  设置时间格式，可更改HH、hh改变日期的显示格式，有12小时和24小时制
 *
 *  @return 时间格式
 */
- (NSString *)timeFormat
{
    NSDate *selected = [self.datePickerView date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:selected];
    return currentOlderOneDateStr;
}

- (void)animationbegin:(UIView *)view
{
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 动画选项设定
    animation.duration = 0.1; // 动画持续时间
    animation.repeatCount = -1; // 重复次数
    animation.autoreverses = YES; // 动画结束时执行逆动画
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    
    // 添加动画
    [view.layer addAnimation:animation forKey:@"scale-layer"];
}

/**
 *  取消按钮点击
 */
- (void)removeBtnClick:(id)sender {
    // 开始动画
    [self animationbegin:sender];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 *  确定按钮点击,会触发代理事件
 */
- (void)sureBtnClick:(id)sender {
    // 开始动画
    [self animationbegin:sender];
    self.selectDate = [self timeFormat];
    [self.delegate getSelectDate:self.selectDate type:self.type];
    [self removeBtnClick:nil];
}

/**
 *  点击其他地方移除时间选择器
 */
- (void)backGroundBtnClicked:(id)sender
{
    
    [self removeBtnClick:nil];
}


@end
