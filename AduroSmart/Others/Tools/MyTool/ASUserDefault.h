//
//  ASUserDefault.h
//  Smart Home
//
//  Created by MacBook on 16/8/21.
//  Copyright © 2016年 Trust International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASUserDefault : NSObject
/*缓存用户id*/
+(void)saveUserIDCache:(NSString *)userID;
/*加载用户id缓存*/
+(NSString *)loadUserIDCache;

/**
 *	@brief 缓存用户名.
 *
 *	@param NSString 类型.
 */
+(void)saveUserNameCache:(NSString *)userName;
/**
 *	@brief	加载用户名缓存.
 *
 *	@param 	无.
 */
+(NSString *)loadUserNameCache;
/**
 *	@brief 缓存用户密码.
 *
 *	@param NSString 类型.
 */
+(void)saveUserPasswardCache:(NSString *)passward;
/**
 *	@brief	加载用户名密码缓存.
 *
 *	@param 	无.
 */
+(NSString *)loadUserPasswardCache;

/**
 *	@brief 缓存网关ID.
 *
 *	@param NSString 类型.
 */
+(void)saveGatewayIDCache:(NSString *)GatewayID;
/**
 *	@brief	加载网关ID缓存.
 *
 *	@param 	无.
 */
+(NSString *)loadGatewayIDCache;
/**
 *	@brief	删除网关ID缓存.
 *
 *	@param 	无.
 */
+(void)deleteGatewayIDCache;


/**
 *	@brief 缓存网关key.
 *
 *	@param NSString 类型.
 */
+(void)saveGatewayKeyCache:(NSString *)GatewayKey;
/**
 *	@brief	加载网关key缓存.
 *
 *	@param 	无.
 */
+(NSString *)loadGatewayKeyCache;

/**
 *	@brief 缓存网关对象.
 *
 *	@param 网关对象 类型.
 */
+(void)saveGatewayCache:(AduroGateway *)gateway;
/**
 *	@brief	加载网关对象.
 *
 *	@param 	无.
 */
+(AduroGateway *)loadGatewayCache;









///**
// *	@brief	保存是否记住用户名标记.
// *
// *	@param 布尔值  YES or NO.
// */
//+(void)saveUserNameIsRemember:(BOOL)isRemember;
//
///**
// *	@brief	  加载是否记住用户名标记
// *
// *	@return bool 类型 YES or NO.
// */
//+ (BOOL)loadUserIsRemember;
@end
