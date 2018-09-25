//
//  ASRoomViewCell.h
//  AduroSmart
//
//  Created by MacBook on 2017/1/3.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASRoomViewCell : UICollectionViewCell
@property(nonatomic,strong) UIImageView *homeTypeImgView;  //代表房间类型的图标
@property(nonatomic,strong) UILabel *homeNameLb;

@property(nonatomic,strong) UIImageView *leftImgView;  //左箭头
@property(nonatomic,strong) UIImageView *rightImgView;  //右箭头
@end
