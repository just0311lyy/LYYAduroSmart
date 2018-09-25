//
//  ASListCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASListCell : UITableViewCell

@property (nonatomic,strong) UILabel *txtLabel;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UIView *cellView;
+(CGFloat)getCellHeight;
@end
