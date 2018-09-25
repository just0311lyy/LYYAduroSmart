//
//  ASTimeTaskDeviceSelectView.m
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeTaskDeviceSelectView.h"

@implementation ASTimeTaskDeviceSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.bottomLineView = [[UIView alloc] init];
        [self addSubview:self.bottomLineView];
        self.deviceImgView = [[UIImageView alloc] init];
        [self addSubview:self.deviceImgView];
        self.arrowImgView = [[UIImageView alloc] init];
//        [self addSubview:self.arrowImgView];
        self.deviceNameLb = [[UILabel alloc] init];
        [self addSubview:self.deviceNameLb];
        self.deviceDetailLb = [[UILabel alloc] init];
        [self addSubview:self.deviceDetailLb];
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    //左边 设备图
    self.deviceImgView.frame = CGRectMake(10,(height - 50)/2, 50, 50);
    
    //下划线
    self.bottomLineView.backgroundColor = CELL_LIEN_COLOR;
    self.bottomLineView.frame = CGRectMake(10, height-1, width, 1);
    //左边设备名
    self.deviceNameLb.frame = CGRectMake(65, 0, width -65 - 30, height/2);
    self.deviceNameLb.textAlignment = NSTextAlignmentLeft;
    //左边 设备详情名
    self.deviceDetailLb.frame = CGRectMake(65, height/2,width -65 - 30, height/2);
    self.deviceDetailLb.font = [UIFont systemFontOfSize:14];
    self.deviceDetailLb.textColor = [UIColor lightGrayColor];
    self.deviceDetailLb.textAlignment = NSTextAlignmentLeft;
    //右边箭头
    self.arrowImgView.frame = CGRectMake(width-30, (height - 18)/2, 18, 18);
    self.arrowImgView.image = [UIImage imageNamed:@"arrow"];
   
}

@end
