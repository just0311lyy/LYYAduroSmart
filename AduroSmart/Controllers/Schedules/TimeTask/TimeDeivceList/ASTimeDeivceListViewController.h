//
//  ASTimeDeivceListViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@class ASTimeDeivceListViewController;

@protocol ASTimeDeivceListViewControllerDelegate <NSObject>

@optional

- (void)selectTaskViewController:(ASTimeDeivceListViewController *)selectedVC didSelectDevice:(AduroDevice *)deviceInfo withSignString:(NSString *)signString withColor:(UIColor *)color withLevel:(CGFloat)level withIsSwitchOn:(BOOL)isSwitchOn;

@end

@interface ASTimeDeivceListViewController : ASBaseViewController

@property (nonatomic, weak) id<ASTimeDeivceListViewControllerDelegate> delegate;
@property (nonatomic , copy) NSString *deviceType;
@end
