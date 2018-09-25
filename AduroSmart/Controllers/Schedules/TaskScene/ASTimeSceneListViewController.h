//
//  ASTimeSceneListViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"
@class ASTimeSceneListViewController;

@protocol ASTimeSceneSelectedDelegate <NSObject>

@optional

- (void)selectTimeSceneViewController:(ASTimeSceneListViewController *)selectedVC didSelectScene:(AduroScene *)sceneInfo withSignString:(NSString *)signString;

@end

@interface ASTimeSceneListViewController : ASBaseViewController

@property (nonatomic, weak) id<ASTimeSceneSelectedDelegate> delegate;

@end
