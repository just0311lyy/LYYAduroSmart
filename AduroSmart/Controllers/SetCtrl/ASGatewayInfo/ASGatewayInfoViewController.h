//
//  ASGatewayInfoViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/9/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@protocol ASGatewayInfoDelegate <NSObject>

-(void)deleteAduroGatewayCache:(AduroGateway *)aduroGateway;

@end


@interface ASGatewayInfoViewController : ASBaseViewController
@property (nonatomic,assign) id<ASGatewayInfoDelegate> delegate;
@property (nonatomic,strong) AduroGateway *currentGateway;

@end
