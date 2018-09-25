//
//  ASUserDefault.m
//  Smart Home
//
//  Created by MacBook on 16/8/21.
//  Copyright © 2016年 Trust International B.V. All rights reserved.
//

#import "ASUserDefault.h"

@implementation ASUserDefault
static  NSString *ASGatewayIDStr = @"gatewayIDStr";
static  NSString *ASGatewayKeyStr = @"ASGatewayKeyStr";
static  NSString *ASUserNameStr = @"ASUserNameStr";
static  NSString *ASUserIDStr = @"ASUserIDStr";
static  NSString *ASPasswardStr = @"ASPasswardStr";
/*缓存用户名id*/
+(void)saveUserIDCache:(NSString *)userID{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userID forKey:ASUserIDStr];
    [ud synchronize];
}
/*加载用户名id缓存*/
+(NSString *)loadUserIDCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *userIDString = [ud objectForKey:ASUserIDStr];
    return userIDString;
    
}

/*缓存用户名*/
+(void)saveUserNameCache:(NSString *)userName{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userName forKey:ASUserNameStr];
    [ud synchronize];
}
/*加载用户名缓存*/
+(NSString *)loadUserNameCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *userNameString = [ud objectForKey:ASUserNameStr];
    return userNameString;
}
/** 缓存用户密码*/
+(void)saveUserPasswardCache:(NSString *)passward{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:passward forKey:ASPasswardStr];
    [ud synchronize];
}
/** 加载用户名密码缓存 */
+(NSString *)loadUserPasswardCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *passwardString = [ud objectForKey:ASPasswardStr];
    return passwardString;
}
/*缓存网关ID*/
+(void)saveGatewayIDCache:(NSString *)gatewayIDStr{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:gatewayIDStr forKey:ASGatewayIDStr];
    [ud synchronize];
    
}
/*加载网关ID缓存*/
+(NSString *)loadGatewayIDCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *gatewayString = [ud objectForKey:ASGatewayIDStr];
    return gatewayString;
}
/*删除网关ID缓存*/
+(void)deleteGatewayIDCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:ASGatewayIDStr];
    [ud synchronize];
}

/* 缓存网关key */
+(void)saveGatewayKeyCache:(NSString *)GatewayKey{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:GatewayKey forKey:ASGatewayKeyStr];
    [ud synchronize];
    
}
/* 加载网关key缓存 */
+(NSString *)loadGatewayKeyCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *gatewayKeyString = [ud objectForKey:ASGatewayKeyStr];
    return gatewayKeyString;
}
/*删除网关key缓存*/
+(void)deleteGatewayKeyCache{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:ASGatewayKeyStr];
    [ud synchronize];
}

/*缓存网关对象*/
+(void)saveGatewayCache:(AduroGateway *)gateway{
    NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:gateway];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:encodeData forKey:@"CurrentGateway"];
    [ud synchronize];
}
/*加载网关对象*/
+(AduroGateway *)loadGatewayCache{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [defaults objectForKey:@"CurrentGateway"];
    AduroGateway *gateway = (AduroGateway *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    return gateway;
}

@end
