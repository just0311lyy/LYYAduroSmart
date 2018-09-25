//
//  ASAboutCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASAboutCell : UITableViewCell

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *IDNumberLabel;
@property (nonatomic,strong) UILabel *modelNumberLabel;
@property (nonatomic,strong) UILabel *versionLabel;
@property (nonatomic,strong) UIView *cellView;
+(CGFloat)getCellHeight;

@end
