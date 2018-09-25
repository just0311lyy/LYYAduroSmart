//
//  ASSensorStateCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASSensorStateCell : UITableViewCell
@property (nonatomic,strong) UILabel *sensorNameLl;
@property (nonatomic,strong) UIImageView *sensorImgView;
@property (nonatomic,strong) UIView *cellView;
+(CGFloat)getCellHeight;
@end
