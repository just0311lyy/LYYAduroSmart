//
//  ASQRCodeViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASQRCodeViewController : UIViewController
{
    BOOL isInitUI;
}
/**
 *  取消扫码
 */
@property (nonatomic, copy) void (^ASQRCodeCancleBlock) (ASQRCodeViewController *);

/**
 *  扫码成功, 返回结果
 */
@property (nonatomic, copy) void (^ASQRCodeSuncessBlock) (ASQRCodeViewController *, NSString *);

/**
 *  扫码失败
 */
@property (nonatomic, copy) void (^ASQRCodeFailBlock) (ASQRCodeViewController *);


@property (nonatomic,strong)AduroGateway *aduroGatewayInfo;

@end
