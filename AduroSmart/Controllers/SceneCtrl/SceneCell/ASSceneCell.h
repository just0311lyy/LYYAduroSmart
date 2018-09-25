//
//  ASSceneCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/26.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASSceneDelegate <NSObject>

//aduro 回调方法
-(BOOL)sceneSwitch:(BOOL)isSceneOn aduroInfo:(AduroScene *)sceneInfo;
//-(void)sceneShowDetailWithGroupInfo:(AduroScene *)aduroSceneInfo;
//aduro 回调方法结束

@end


@interface ASSceneCell : UITableViewCell
@property (nonatomic,assign) id<ASSceneDelegate> delegate;
@property (nonatomic,strong) AduroScene *aduroSceneInfo;
//@property(nonatomic,strong) UIButton *sceneSwitchBtn;
@property(nonatomic,strong) UIButton *sceneShowDetailBtn;
@property (nonatomic,strong) UILabel *sceneNameLb;
@property (nonatomic,strong) UILabel *netStateLb;
+(CGFloat)getCellHeight;
@end
