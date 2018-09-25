//
//  ASTimeTaskSceneSelectView.m
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeTaskSceneSelectView.h"

@implementation ASTimeTaskSceneSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.bottomLineView = [[UIView alloc] init];
        [self addSubview:self.bottomLineView];
        self.sceneImgView = [[UIImageView alloc] init];
        [self addSubview:self.sceneImgView];
        self.arrowImgView = [[UIImageView alloc] init];
        [self addSubview:self.arrowImgView];
        self.sceneNameLb = [[UILabel alloc] init];
        [self addSubview:self.sceneNameLb];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    //左边 设备图
    self.sceneImgView.frame = CGRectMake(10,(height - 50)/2, 50, 50);
    //下划线
    self.bottomLineView.backgroundColor = CELL_LIEN_COLOR;
    self.bottomLineView.frame = CGRectMake(10, height-1, width, 1);
    //左边设备名
    self.sceneNameLb.frame = CGRectMake(65, 0, width -65 - 30, height);
    self.sceneNameLb.textAlignment = NSTextAlignmentLeft;
    //右边箭头
    self.arrowImgView.frame = CGRectMake(width-30, (height - 18)/2, 18, 18);
    self.arrowImgView.image = [UIImage imageNamed:@"arrow"];
    
}


@end
