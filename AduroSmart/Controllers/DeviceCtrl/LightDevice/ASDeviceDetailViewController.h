//
//  ASDeviceDetailViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"
#import "InfColorBarPicker.h"
#import "InfColorSquarePicker.h"

@class ASDeviceDetailViewController;

@protocol ASDeviceDetailDelegate <NSObject>

@optional

- (void)selectViewController:(ASDeviceDetailViewController *)selectedVC didSelectColor:(UIColor *)color;

@end
@interface ASDeviceDetailViewController : ASBaseViewController<KZColorPickerColorChangeDelegate,KZColorBarChangeDelegate>{
    UIView *_topColorBtnView;
    UIView *_colorTemperatureView;
    UIView *_colorView;
    UIView *_defaultView;
    //色温调节器
    InfColorBarPicker *_colorTemperaturePicker;
    //颜色调节器
    InfColorSquarePicker *_colorPicker;
    //默认调节器
    InfColorSquarePicker *_defaultPicker;
//    //亮度调节器
//    UISlider *_alphaSlider;

    UIButton *_colorBtn;
    UIButton *_whiteBtn;
    UIButton *_defaultBtn;
  
    DeviceManager *_manager;

    
    BOOL _isShowTestColorView;
    UIView *_viewTestColor;
    NSArray *_colorArray;
    UITextField *h;
    UITextField *s;    
}
@property (nonatomic,assign) id<ASDeviceDetailDelegate> delegate;
@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;

@property (nonatomic,strong) AduroGroup *currentAduroGroup; //通过房间调节房间内的灯的色彩。
@end
