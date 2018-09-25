//
//  ASTimeTaskModelView.h
//  AduroSmart
//
//  Created by MacBook on 16/9/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASTimeTaskModelView : UIView

@property(nonatomic,strong) UIView *topLineView;
@property(nonatomic,strong) UIView *bottomLineView;
@property(nonatomic,strong) UILabel *nameLb;
@property(nonatomic,strong) UILabel *detailLb;
@property(nonatomic,strong) UIImageView *leftImgView;
@property(nonatomic,strong) UIImageView *arrowImgView;

//@property(nonatomic,strong) UIButton *switchBtn;

@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *colorView;
@property(nonatomic,strong) UILabel *levelLb;
@property(nonatomic,strong) UILabel *switchLb;
@end
