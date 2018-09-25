//
//  ASTimeTaskModelView.m
//  AduroSmart
//
//  Created by MacBook on 16/9/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeTaskModelView.h"

@implementation ASTimeTaskModelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.topLineView = [[UIView alloc] init];
        [self addSubview:self.topLineView];
        self.bottomLineView = [[UIView alloc] init];
        [self addSubview:self.bottomLineView];
        self.leftImgView = [[UIImageView alloc] init];
        [self addSubview:self.leftImgView];
        self.arrowImgView = [[UIImageView alloc] init];
        //        [self addSubview:self.arrowImgView];
        
        self.nameLb = [[UILabel alloc] init];
        [self addSubview:self.nameLb];
        self.detailLb = [[UILabel alloc] init];
//        [self addSubview:self.detailLb];
        self.bottomView = [[UIView alloc] init];
        [self addSubview:self.bottomView];
        self.colorView = [[UIView alloc] init];
        [self.bottomView addSubview:self.colorView];
        self.levelLb = [[UILabel alloc] init];
        [self.bottomView addSubview:self.levelLb];
        self.switchLb = [[UILabel alloc] init];
        [self.bottomView addSubview:self.switchLb];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    //左边 设备图
    self.leftImgView.frame = CGRectMake(10,5, 60, 60);
    
    //上划线
    self.topLineView.backgroundColor = CELL_LIEN_COLOR;
    self.topLineView.frame = CGRectMake(10, 0, width-10, 1);
    //下划线
    self.bottomLineView.backgroundColor = CELL_LIEN_COLOR;
    self.bottomLineView.frame = CGRectMake(10, height-1, width-10, 1);
    //左边名
    self.nameLb.frame = CGRectMake(80, self.leftImgView.frame.origin.y, width -65 - 30, self.leftImgView.frame.size.height);
    self.nameLb.textAlignment = NSTextAlignmentLeft;
    
//    //左边 详情名
//    self.detailLb.frame = CGRectMake(65, height/2,width -65 - 30, height/2);
//    self.detailLb.font = [UIFont systemFontOfSize:14];
//    self.detailLb.textColor = [UIColor lightGrayColor];
//    self.detailLb.textAlignment = NSTextAlignmentLeft;
//    //右边箭头
//    self.arrowImgView.frame = CGRectMake(width-30, (height - 18)/2, 18, 18);
//    self.arrowImgView.image = [UIImage imageNamed:@"arrow"];
    
    //色彩或色温和亮度显示视图
    self.bottomView.frame = CGRectMake(width - 160, height - 5 - 40, 100, 40);
    
    //开关
    self.switchLb.frame = CGRectMake(100, 0, 40, 40);
    [self.switchLb setFont:[UIFont systemFontOfSize:16]];
    [self.switchLb setTextAlignment:NSTextAlignmentCenter];
    self.switchLb.contentMode = UIViewContentModeScaleAspectFit;
    self.switchLb.layer.cornerRadius =20.0;
    self.switchLb.layer.masksToBounds = YES;
    self.switchLb.layer.borderColor = [UIColor blackColor].CGColor;
    self.switchLb.layer.borderWidth = 0.5;
    
    self.levelLb.frame = CGRectMake(50,0, 40, 40);
    [self.levelLb setFont:[UIFont systemFontOfSize:14]];
    [self.levelLb setTextAlignment:NSTextAlignmentCenter];
    self.levelLb.contentMode = UIViewContentModeScaleAspectFit;
    self.levelLb.layer.cornerRadius =20.0;
    self.levelLb.layer.masksToBounds = YES;
    self.levelLb.layer.borderColor = [UIColor blackColor].CGColor;
    self.levelLb.layer.borderWidth = 0.5;
    
    self.colorView.frame = CGRectMake(0,0, 40, 40);
    self.colorView.contentMode = UIViewContentModeScaleAspectFit;
    self.colorView.layer.cornerRadius = 20.0;
    self.colorView.layer.masksToBounds = YES;
    self.colorView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.colorView.layer.borderWidth = 0.5;
}

@end
