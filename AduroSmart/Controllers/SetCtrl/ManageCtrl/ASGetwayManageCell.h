//
//  ASGetwayManageCell.h
//  AduroSmart
//
//  Created by MacBook on 16/9/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASGetwayManageCellDelegate <NSObject>
//显示详情
-(void)gatewayShowDetailWithAduroGateway:(AduroGateway *)aduroGateway;

@end

@interface ASGetwayManageCell : UITableViewCell

@property (nonatomic,assign) id<ASGetwayManageCellDelegate> delegate;
@property (nonatomic,strong) AduroGateway *aduroGatewayInfo;

+(CGFloat)getCellHeight;


@end
