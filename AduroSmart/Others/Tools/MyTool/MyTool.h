#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+MD5.h"
@interface MyTool : NSObject


+(UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
/**
 *@brief 根据时间戳计算出日期
 */
+(NSString*)TimestampToDate:(NSString*)timestamp;


/**
 *@brief 根据时间戳计算出日期加时间
 */
+(NSDate*)TimestampToDateAndTime:(NSString*)timestamp;

/**
 *  传入一个日期对象返回日期加时间的字符串
 *
 *  @param date 日期对象
 *
 *  @return 日期加时间的字符串
 */
+(NSString *)stringFromDate:(NSDate *)date;


/**
 *@brief 获得当前的时间，例如2013-08-11 16:05:03
 */
+(NSString*)getCurrentDateString;

/**
 *@brief 获得当前的时间戳，例如13893497234
 */
+(NSString*)getCurrentTimestampString;

/**
 *@brief 判断字符串是否全部为数字
 */
+(BOOL)stringIsDigit:(NSString*)inputStr;

/**
 *@brief 获得应用的沙盒路径
 */
+ (NSString *)applicationDocumentsDirectory;



/**
 *@brief url中有中文的情况使用此方法转为UTF-8
 */
+(NSString*)stringCovertToUTF8:(NSString *)urlString;

/**
 *@brief 性别的代码与字符串之间的转换
 */
+(NSString*)sexCodeCovertString:(NSString*)sexCode;

/**
 *@brief 时间字符串转时间戳
 */
+(NSString*)dateNSStringToTimestamp:(NSString*)dateNSString;



/**
 *  读取一个设备标示给插座来区分不同手机用
 *
 *  @return 字符串
 */
+(NSString*)readUUID;


/**
 *  获得一个类似标示符
 *
 *  @return 字符串
 */
+(NSString *)readLocalMac;


/**
 *  过滤从广播中得来的ip地址中的非法字符串
 *
 *  @param oriangeIPAddress 未过滤的源ip地址
 *
 *  @return 过滤后的ip地址
 */
+(NSString *)filterIPAddress:(NSString *)oriangeIPAddress;


/**
 *  @author xingman.yi, 16-01-15 15:01:02
 *
 *  @brief 将16进制字符串转化为二进制字符串
 *
 *  @param hex 16进制字符串
 *
 *  @return 二进制字符串
 */
+(NSString *)getBinaryStrByHex:(NSString *)hex;

/**
 *  @author xingman.yi, 16-01-15 15:01:02
 *
 *  @brief 将二进制字符串转化为16进制字符串
 *
 *  @param binary 二进制字符串
 *
 *  @return 16进制字符串
 */
+(NSString *)getStrHexByBinary:(NSString *)binary;

/**
 *  @author xingman.yi, 16-01-18 16:01:26
 *
 *  @brief 翻转字符串
 *
 *  @param str 原始字符串
 *
 *  @return 翻转之后的字符串
 */
+(NSString *)reverseStr:(NSString *)str;

/**
 *  @author xingman.yi, 16-03-17 09:03:27
 *
 *  @brief 加模糊效果
 *
 *  @param image 要加模糊前图片
 *  @param blur  模糊程度
 *
 *  @return 增加模糊效果后的图片
 */
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

+(NSString *)changeName:(NSString *)old;

+(void)saveImageToDisk:(UIImage *)image fileName:(NSString *)fileName;

+(UIImage *)readImageFromDisk:(NSString *)result;

/**
 *  @author 16-01-18 16:01:26
 *
 *  @brief 通过整型数转换为星期
 *
 *  @param iday 无符号整型
 *
 *  @return 周几
 */
+(NSString *)weekConverByIday:(NSInteger )iday;

@end
