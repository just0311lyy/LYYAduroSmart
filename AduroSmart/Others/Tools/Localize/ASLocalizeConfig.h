//
//  ASLocalizeConfig.h
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>

//设置语言函名标签
#define AS_LANGUAGE_IDENTIFIER @"AS_languageIdentifierString"
//当前系统的语言种类：
#define CURRENT_LANGUAGE  ([[NSLocale preferredLanguages] objectAtIndex:0])

@interface ASLocalizeConfig : NSObject

//语言本地化
+(NSString *)localizedString:(NSString *)localizedStrKey;
//语言初始化判断
+(void)initializeLanguageIdentifierString;

@end
