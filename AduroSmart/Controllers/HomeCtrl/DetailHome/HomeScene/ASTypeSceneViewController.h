//
//  ASTypeSceneViewController.h
//  AduroSmart
//
//  Created by MacBook on 2016/11/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"
@class ASTypeSceneViewController;

@protocol ASTypeSceneSelectedDelegate <NSObject>

@optional

- (void)selectTypeSceneViewController:(ASTypeSceneViewController *)selectedVC didSelectString:(NSString *)typeName;

@end

@interface ASTypeSceneViewController : ASBaseViewController

@property (nonatomic, weak) id<ASTypeSceneSelectedDelegate> delegate;

@end
