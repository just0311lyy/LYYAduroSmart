//
//  ASRootTabBarViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASRootTabBarViewController.h"
#import "ASDeviceListViewController.h"
#import "ASHomeViewController.h"
#import "ASSceneViewController.h"
#import "ASSchedulesViewController.h"
#import "ASSetViewController.h"
#import "UIColor+String.h"
#import "ASLocalizeConfig.h"

@interface ASRootTabBarViewController ()

@end

@implementation ASRootTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //房间
    ASHomeViewController *homeVC = [[ASHomeViewController alloc]init];
    homeVC.title = [ASLocalizeConfig localizedString:@"房间"];
    UINavigationController *homeNavc = [[UINavigationController alloc]initWithRootViewController:homeVC];
    homeNavc.tabBarItem.title = [ASLocalizeConfig localizedString:@"房间"];
    UIImage *homeImage = [[UIImage imageNamed:@"tab_home_unclick"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeNavc.tabBarItem.image = homeImage;
    UIImage *homeSelectedImage = [[UIImage imageNamed:@"tab_home_click"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeNavc.tabBarItem.selectedImage = homeSelectedImage;
    
    // 设备
    ASDeviceListViewController *deviceVC = [[ASDeviceListViewController alloc]init];
    deviceVC.title = [ASLocalizeConfig localizedString:@"设备"];
    UINavigationController *deviceNavc = [[UINavigationController alloc]initWithRootViewController:deviceVC];
    deviceNavc.tabBarItem.title = [ASLocalizeConfig localizedString:@"设备"];
    UIImage *deviceImage = [UIImage imageNamed:@"devices"];
    deviceNavc.tabBarItem.image = deviceImage;
    UIImage *deviceSelectedImage = [UIImage imageNamed:@"devices_selected"];
    deviceNavc.tabBarItem.selectedImage = deviceSelectedImage;
    
//    //摄像头
//    CameraListController *cameraListCtrl = [[CameraListController alloc]init];
//    BaseNavigationController *cameraListNavCtrl = [[BaseNavigationController alloc] initWithRootViewController:cameraListCtrl];
//    cameraListNavCtrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ipcamera", @"IPCam") image:[UIImage imageNamed:@"icon-camera"] tag:2];
    // 场景
    ASSceneViewController *sceneVC = [[ASSceneViewController alloc]init];
    sceneVC.title = [ASLocalizeConfig localizedString:@"场景"];
    UINavigationController *sceneNavc = [[UINavigationController alloc]initWithRootViewController:sceneVC];
    sceneNavc.tabBarItem.title = [ASLocalizeConfig localizedString:@"场景"];
    UIImage *sceneImage = [UIImage imageNamed:@"scene"];
    sceneNavc.tabBarItem.image = sceneImage;
    UIImage *sceneSelectedImage = [UIImage imageNamed:@"scene_selected"];
    sceneNavc.tabBarItem.selectedImage = sceneSelectedImage;
    
    // 时间表
    ASSchedulesViewController *schedulesVC = [[ASSchedulesViewController alloc]init];
    schedulesVC.title = [ASLocalizeConfig localizedString:@"任务"];
    UINavigationController *schedulesNavc = [[UINavigationController alloc]initWithRootViewController:schedulesVC];
    schedulesNavc.tabBarItem.title = [ASLocalizeConfig localizedString:@"任务"];
    UIImage *schedulesImage = [[UIImage imageNamed:@"tab_time_unclick"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    schedulesNavc.tabBarItem.image = schedulesImage;
    UIImage *schedulesSelectedImage = [[UIImage imageNamed:@"tab_time_click"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    schedulesNavc.tabBarItem.selectedImage = schedulesSelectedImage;

    // 设置
    ASSetViewController *setVC = [[ASSetViewController alloc]init];
    setVC.title = [ASLocalizeConfig localizedString:@"设置"];
    UINavigationController *setNavc = [[UINavigationController alloc]initWithRootViewController:setVC];
    setNavc.tabBarItem.title = [ASLocalizeConfig localizedString:@"设置"];
    UIImage *setImage = [[UIImage imageNamed:@"tab_set_unclick"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    setNavc.tabBarItem.image = setImage;
    UIImage *setSelectedImage = [[UIImage imageNamed:@"tab_set_click"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    setNavc.tabBarItem.selectedImage = setSelectedImage;
    
    //tabbar选中的颜色
//    [[UITabBar appearance] setBackgroundColor:LOGO_COLOR];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabBar_bg"]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : UIColorFromRGB(0x573500) }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
                                             forState:UIControlStateSelected];
    //---
    [UITabBar appearance].translucent = YES; //半透明
    [UITabBar appearance].clipsToBounds = YES; //显示出多余的
    
    self.viewControllers = @[/*deviceNavc,*/homeNavc,/*sceneNavc,*/schedulesNavc,setNavc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
