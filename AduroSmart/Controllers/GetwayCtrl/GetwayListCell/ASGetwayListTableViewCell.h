//
//  ASGetwayListTableViewCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/14.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASGetwayListTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *getwayIpNameLb;
@property (nonatomic,strong) UILabel *getwayNumberNameLb;
+(CGFloat)getCellHeight;
@end
