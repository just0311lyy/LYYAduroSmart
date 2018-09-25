//
//  ASTypeGroupViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/8/4.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@class ASTypeGroupViewController;

@protocol ASTypeGroupSelectedDelegate <NSObject>

@optional

- (void)selectTypeGroupViewController:(ASTypeGroupViewController *)selectedVC didSelectString:(NSString *)typeName andImageName:(NSString *)imageName andTypeId:(NSString *)typeId;

@end


@interface ASTypeGroupViewController : ASBaseViewController

@property (nonatomic, weak) id<ASTypeGroupSelectedDelegate> delegate;

@end
