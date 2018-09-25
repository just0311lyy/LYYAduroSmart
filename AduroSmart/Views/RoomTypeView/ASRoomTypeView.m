//
//  ASRoomTypeView.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASRoomTypeView.h"

@implementation ASRoomTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.topLineView = [[UIView alloc] init];
        [self addSubview:self.topLineView];
        self.bottomLineView = [[UIView alloc] init];
        [self addSubview:self.bottomLineView];
        self.roomImgView = [[UIImageView alloc] init];
        [self addSubview:self.roomImgView];
        self.arrowImgView = [[UIImageView alloc] init];
        [self addSubview:self.arrowImgView];
        self.typeNameLb = [[UILabel alloc] init];
        [self addSubview:self.typeNameLb];
        self.roomNameLb = [[UILabel alloc] init];
        [self addSubview:self.roomNameLb];
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //上划线
//    self.topLineView.backgroundColor = UIColorFromRGB(0xd2d2d2);
    self.topLineView.frame = CGRectMake(0, 0, width, 1);
    //下划线
//    self.bottomLineView.backgroundColor = CELL_LIEN_COLOR;
    self.bottomLineView.frame = CGRectMake(0, height-1, width, 1);
    //左边名
    self.typeNameLb.frame = CGRectMake(23, (height - 40)/2, 100, 40);
    self.typeNameLb.textColor = [UIColor whiteColor];
    //右边箭头
    self.arrowImgView.frame = CGRectMake(width-30, (height - 23/1.3)/2, 13/1.3, 23/1.3);
    self.arrowImgView.image = [UIImage imageNamed:@"arrow_white"];

    //右边 内容名
    self.roomNameLb.frame = CGRectMake(self.arrowImgView.frame.origin.x - 90, (height - 40)/2, 90, 40);
    self.roomNameLb.textAlignment = NSTextAlignmentCenter;
    self.roomNameLb.textColor = [UIColor whiteColor];
    //右边 内容图
    self.roomImgView.frame = CGRectMake(self.roomNameLb.frame.origin.x - 35,(height - 35)/2, 35, 35);

  
}





@end
