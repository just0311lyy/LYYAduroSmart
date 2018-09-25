//
//  ASLoginViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/7/11.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@interface ASLoginViewController : ASBaseViewController
  
////登录 block
//@property (nonatomic,copy) void (^loginBlock)(BOOL success, NSString *error) ;
//@property (nonatomic,copy) void (^registerBlock)();
//
//@property (nonatomic,copy) void (^forgetBlock)();

@property(nonatomic,copy) NSString *setPushStr;

@end
