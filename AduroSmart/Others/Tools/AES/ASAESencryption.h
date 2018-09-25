//
//  ASAESencryption.h
//  Smart Home
//
//  Created by MacBook on 2016/12/8.
//  Copyright © 2016年 Trust International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASAESencryption : NSObject

+(NSData *)AES256ParmEncryptWithKey:(NSString *)key Encrypttext:(NSData *)text;   //加密
+(NSData *)AES256ParmDecryptWithKey:(NSString *)key Decrypttext:(NSData *)text;   //解密
+(NSString *) aes256_encrypt:(NSString *)key Encrypttext:(NSString *)text;
+(NSString *) aes256_decrypt:(NSString *)key Decrypttext:(NSString *)text;

@end
