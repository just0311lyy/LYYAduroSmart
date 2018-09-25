//
//  ASServerViewController.h
//  AduroSmart
//
//  Created by MacBook on 2016/12/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@class ASServerViewController;

@protocol ASServerViewControllerDelegate <NSObject>

@optional

- (void)selectViewController:(ASServerViewController *)selectedVC didSelectServer:(NSString *)serverName;

@end

@interface ASServerViewController : ASBaseViewController

@property (nonatomic, weak) id<ASServerViewControllerDelegate> delegate;

@end
