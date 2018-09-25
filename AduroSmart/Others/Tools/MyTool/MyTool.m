#import "MyTool.h"
#import <Accelerate/Accelerate.h>
#import "AppDelegate.h"


@implementation MyTool

/**
 *@brief 重新设置图片的大小
 */
+(UIImage *)scale:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

/**
 *@brief 判断字符串是否全部为数字
 */
+(BOOL)stringIsDigit:(NSString*)inputStr{
    int inputStrLength = (int)[inputStr length];
    char *covertChar = (char *)[inputStr cStringUsingEncoding:NSASCIIStringEncoding];
    for(int i=0;i<inputStrLength;i++)
    {
        if(covertChar[i]<='0' || covertChar[i]>='9')
        {
            return NO;
        }
    }
    return YES;
}



/**
 *@brief 根据时间戳计算出时间
 */
+(NSString*)TimestampToDate:(NSString*)timestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:NSLocalizedString(@"PerformDate", @"")];//@"yyyy年MM月dd日"
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];  
    [formatter setTimeZone:timeZone];
    NSDate *datestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    
    if (![self stringIsDigit:timestamp]) {
        return timestamp;
    }
    return [formatter stringFromDate:datestamp];
}

/**
 *@brief 根据时间戳计算出日期加时间,返回日期对象
 */
+(NSDate*)TimestampToDateAndTime:(NSString*)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:NSLocalizedString(@"PerformDateAndTime", @"")];    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:[timestamp integerValue]];
    return d;
}

/**
 *  传入一个日期对象返回日期加时间的字符串
 *
 *  @param date 日期对象
 *
 *  @return 日期加时间的字符串
 */
+(NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


/**
 *@brief 时间字符串转时间戳
 */
+(NSString*)dateNSStringToTimestamp:(NSString*)dateNSString{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[NSLocale currentLocale]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:dateNSString];
    NSString *timeSp = [[NSString alloc]initWithFormat:@"%ld", (long)[inputDate timeIntervalSince1970]];
    return timeSp;
}
/**
 *@brief 角度转换为弧度
 */
+(double)radians:(float)degrees{
    return (degrees*3.14159265)/180.0;
}


/**
 *@brief 获得当前的时间，例如2013-08-11 16:05:03
 */
+(NSString*)getCurrentDateString{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH:mm:ss"];
    NSString *  morelocationString=[dateformatter stringFromDate:senddate];
    return morelocationString;
}

/**
 *@brief 获得当前的时间戳，例如13893497234
 */
+(NSString *)getCurrentTimestampString{
    NSDate * today = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:today];
    NSDate *localeDate = [today dateByAddingTimeInterval:interval];
    NSLog(@"%@", localeDate);
    // 时间转换成时间戳
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[localeDate timeIntervalSince1970]];
    return timeSp;
}




/**
 *@brief 判断输入的email是否正确
 */
- (BOOL)CheckInputIsEmail:(NSString *)inputStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9._]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:inputStr];
}


/**
 *@brief 判断输入的手机号码是否正确
 */
-(BOOL)CheckInputIsTelNum:(NSString *)_text
{
    NSString *Regex = @"1\\d{10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [emailTest evaluateWithObject:_text];  
}






/**
 *@brief 获得应用的沙盒路径
 */
+ (NSString *)applicationDocumentsDirectory{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}




/**
 *@brief url中有中文的情况使用此方法转为UTF-8
 */
+(NSString*)stringCovertToUTF8:(NSString *)urlString{
    NSString *encodingString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodingString;
}


/**
 *@brief 性别的代码与字符串之间的转换
 */
+(NSString*)sexCodeCovertString:(NSString*)sexCode{
    if ([sexCode isEqualToString:@"0"]) {
        return NSLocalizedString(@"NSStringSexMan",@"男");
    }else{
        return NSLocalizedString(@"NSStringSexWoMan",@"女");
    }
}



/**
 *  读取一个设备标示给插座来区分不同手机用
 *
 *  @return 字符串
 */
+(NSString*)readUUID{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

/**
 *  获得一个类似标示符
 *
 *  @return 字符串
 */
+(NSString *)readLocalMac{
    NSString *tempString = [MyTool readUUID];
    NSString *tempString1 = [tempString substringWithRange:NSMakeRange([tempString length]-12, 12)];
    NSMutableString *localMacString = [[NSMutableString alloc]init];
    for (int i=0; i<[tempString1 length]; i++) {
        if (i!=0) {
            if (i%2==0) {
                [localMacString appendFormat:@":"];
            }
        }
        NSString *macsub = [[tempString1 substringWithRange:NSMakeRange(i, 2)] lowercaseString];

        [localMacString appendFormat:@"%@",macsub];
        i++;
    }
    return localMacString;
}


/**
 *  过滤从广播中得来的ip地址中的非法字符串
 *
 *  @param oriangeIPAddress 未过滤的源ip地址
 *
 *  @return 过滤后的ip地址
 */
+(NSString *)filterIPAddress:(NSString *)oriangeIPAddress{
    NSString *sIPAddress = nil;
    if (oriangeIPAddress) {
        sIPAddress = [[NSString alloc]initWithFormat:@"%@",[oriangeIPAddress stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""]];
    }
    return sIPAddress;
}


/**
 *  @author xingman.yi, 16-01-15 15:01:02
 *
 *  @brief 将16进制字符串转化为二进制字符串
 *
 *  @param hex 16进制字符串
 *
 *  @return 二进制字符串
 */
+(NSString *)getBinaryStrByHex:(NSString *)hex
{
    if ([hex isEqualToString:@"0x00"]) {
        return @"0000000";
    }
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    [hexDic setObject:@"1010" forKey:@"a"];
    
    [hexDic setObject:@"1011" forKey:@"b"];
    
    [hexDic setObject:@"1100" forKey:@"c"];
    
    [hexDic setObject:@"1101" forKey:@"d"];
    
    [hexDic setObject:@"1110" forKey:@"e"];
    
    [hexDic setObject:@"1111" forKey:@"f"];
    
    NSMutableDictionary *hexDic0 = [[NSMutableDictionary alloc]init];
    [hexDic0 setObject:@"000" forKey:@"0"];
    
    [hexDic0 setObject:@"001" forKey:@"1"];
    
    [hexDic0 setObject:@"010" forKey:@"2"];
    
    [hexDic0 setObject:@"011" forKey:@"3"];
    
    [hexDic0 setObject:@"100" forKey:@"4"];
    
    [hexDic0 setObject:@"101" forKey:@"5"];
    
    [hexDic0 setObject:@"110" forKey:@"6"];
    
    [hexDic0 setObject:@"111" forKey:@"7"];
    
    NSMutableString *binaryString = [[NSMutableString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        NSString *subBinary = [NSString stringWithFormat:@"%@",[hexDic objectForKey:key]];
        if (([hex length]==2)&&(i==0)) {
            subBinary = [NSString stringWithFormat:@"%@",[hexDic0 objectForKey:key]];
        }
        if ([hex length]==1) {
            [binaryString appendString:@"000"];
        }
        
        
        [binaryString appendString:subBinary];
    }
    DDLogDebug(@"binaryString = %@",binaryString);
    return binaryString;
    
}

/**
 *  @author xingman.yi, 16-01-15 15:01:02
 *
 *  @brief 将二进制字符串转化为16进制字符串
 *
 *  @param binary 二进制字符串
 *
 *  @return 16进制字符串
 */
+(NSString *)getStrHexByBinary:(NSString *)binary
{
    DDLogDebug(@"binary = %@",binary);
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0" forKey:@"000"];
    
    [hexDic setObject:@"1" forKey:@"001"];
    
    [hexDic setObject:@"2" forKey:@"010"];
    
    [hexDic setObject:@"3" forKey:@"011"];
    
    [hexDic setObject:@"4" forKey:@"100"];
    
    [hexDic setObject:@"5" forKey:@"101"];
    
    [hexDic setObject:@"6" forKey:@"110"];
    
    [hexDic setObject:@"7" forKey:@"111"];
    
    [hexDic setObject:@"0" forKey:@"0000"];
    
    [hexDic setObject:@"1" forKey:@"0001"];
    
    [hexDic setObject:@"2" forKey:@"0010"];
    
    [hexDic setObject:@"3" forKey:@"0011"];
    
    [hexDic setObject:@"4" forKey:@"0100"];
    
    [hexDic setObject:@"5" forKey:@"0101"];
    
    [hexDic setObject:@"6" forKey:@"0110"];
    
    [hexDic setObject:@"7" forKey:@"0111"];
    
    [hexDic setObject:@"8" forKey:@"1000"];
    
    [hexDic setObject:@"9" forKey:@"1001"];
    
    [hexDic setObject:@"A" forKey:@"1010"];
    
    [hexDic setObject:@"B" forKey:@"1011"];
    
    [hexDic setObject:@"C" forKey:@"1100"];
    
    [hexDic setObject:@"D" forKey:@"1101"];
    
    [hexDic setObject:@"E" forKey:@"1110"];
    
    [hexDic setObject:@"F" forKey:@"1111"];
    
    [hexDic setObject:@"a" forKey:@"1010"];
    
    [hexDic setObject:@"b" forKey:@"1011"];
    
    [hexDic setObject:@"c" forKey:@"1100"];
    
    [hexDic setObject:@"d" forKey:@"1101"];
    
    [hexDic setObject:@"e" forKey:@"1110"];
    
    [hexDic setObject:@"f" forKey:@"1111"];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    NSRange rage1;
    
    rage1.length = 3;
    
    rage1.location = 0;
    
    NSString *key1 = [binary substringWithRange:rage1];
    
    [hexString appendString:[NSString stringWithFormat:@"0x%@",[hexDic objectForKey:key1]]];
    
    
    NSRange rage2;
    
    rage2.length = 4;
    
    rage2.location = 3;
    
    NSString *key2 = [binary substringWithRange:rage2];
    
    [hexString appendString:[NSString stringWithFormat:@"%@",[hexDic objectForKey:key2]]];
    
    DDLogDebug(@"b = %@,k1 = %@,k2 = %@,hexString = %@",binary,key1,key2,hexString);

    return hexString;
}


/**
 *  @author xingman.yi, 16-01-18 16:01:26
 *
 *  @brief 翻转字符串
 *
 *  @param str 原始字符串
 *
 *  @return 翻转之后的字符串
 */
+(NSString *)reverseStr:(NSString *)str{
    
    unsigned long len;
    len = [str length];
    unichar a[len];
    for(int i = 0; i < len; i++)
    {
        unichar c = [str characterAtIndex:len-i-1];
        a[i] = c;
    }
    NSString *str1=[NSString stringWithCharacters:a length:len];
    return  str1;
}


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
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    @try {
        //模糊度,
        if ((blur < 0.1f) || (blur > 2.0f)) {
            blur = 0.5f;
        }
        
        //boxSize必须大于0
        int boxSize = (int)(blur * 100);
        boxSize -= (boxSize % 2) + 1;
        NSLog(@"boxSize:%i",boxSize);
        //图像处理
        CGImageRef img = image.CGImage;
        //需要引入
        /*
         This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
         本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
         */
        
        //图像缓存,输入缓存，输出缓存
        vImage_Buffer inBuffer, outBuffer;
        vImage_Error error;
        //像素缓存
        void *pixelBuffer;
        
        //数据源提供者，Defines an opaque type that supplies Quartz with data.
        CGDataProviderRef inProvider = CGImageGetDataProvider(img);
        // provider’s data.
        CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
        
        //宽，高，字节/行，data
        inBuffer.width = CGImageGetWidth(img);
        inBuffer.height = CGImageGetHeight(img);
        inBuffer.rowBytes = CGImageGetBytesPerRow(img);
        inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
        
        //像数缓存，字节行*图片高
        pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
        
        outBuffer.data = pixelBuffer;
        outBuffer.width = CGImageGetWidth(img);
        outBuffer.height = CGImageGetHeight(img);
        //        outBuffer.width = [[UIScreen mainScreen]bounds].size.width;
        //        outBuffer.height = [[UIScreen mainScreen]bounds].size.height;
        outBuffer.rowBytes = CGImageGetBytesPerRow(img);
        
        
        // 第三个中间的缓存区,抗锯齿的效果
        void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
        vImage_Buffer outBuffer2;
        outBuffer2.data = pixelBuffer2;
        outBuffer2.width = CGImageGetWidth(img);
        outBuffer2.height = CGImageGetHeight(img);
        outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
        
        //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        
        //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
        //颜色空间DeviceRGB
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
        CGContextRef ctx = CGBitmapContextCreate(
                                                 outBuffer.data,
                                                 outBuffer.width,
                                                 outBuffer.height,
                                                 8,
                                                 outBuffer.rowBytes,
                                                 colorSpace,
                                                 CGImageGetBitmapInfo(image.CGImage));
        
        //根据上下文，处理过的图片，重新组件
        CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
        UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
        
        //clean up
        CGContextRelease(ctx);
        CGColorSpaceRelease(colorSpace);
        
        free(pixelBuffer);
        free(pixelBuffer2);
        CFRelease(inBitmapData);
        
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(imageRef);
        
        return returnImage;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
}


+(NSString *)changeName:(NSString *)old{
    if ([old isEqualToString:@"MainsOutlet"]) {
        return @"Mains Outlet";
    }
    if ([old isEqualToString:@"ToningLamp"]) {
        return @"Color lamp";
    }
    if ([old isEqualToString:@"MontionSensor"]) {
        return @"Motion Sensor";
    }
    
    if ([old isEqualToString:@"ContactSwitchSensor"]) {
        return @"Contact Switch";
    }
    if ([old isEqualToString:@"DimmableLight"]) {
        return @"Dim lamp";
    }
    if ([old isEqualToString:@"ColorTempLight"]) {
        return @"Color Temperature Lamp";
    }
    //为了适应simon购买回来的灯，网关错误识别为Switch
    if ([old isEqualToString:@"Switch"]) {
        return @"Dim lamp";
    }
    if ([old isEqualToString:@"WindowsCover"]) {
        return @"Curtain";
    }
    return old;
}

+(void)saveImageToDisk:(UIImage *)image fileName:(NSString *)fileName{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray * arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [arr objectAtIndex:0];
    path = [path stringByAppendingPathComponent:fileName];
    DDLogDebug(@"saveImageToDisk = %@",path);
    if ([fileMgr fileExistsAtPath:path]) {
        [fileMgr removeItemAtPath:path error:nil];
    }
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}


+(UIImage *)readImageFromDisk:(NSString *)result{
    NSString *fileName = [[NSString alloc]initWithFormat:@"%@.png",[result md5EncryptLower]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray * arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [arr objectAtIndex:0];
    path = [path stringByAppendingPathComponent:fileName];
    if (![fileMgr fileExistsAtPath:path]) {
        return nil;
    }
    DDLogDebug(@"readImageFromDisk = %@",path);
    return [UIImage imageWithContentsOfFile:path];
}

/**
 *  @author 16-01-18 16:01:26
 *
 *  @brief 通过整型数转换为星期
 *
 *  @param iday 无符号整型
 *
 *  @return 周几
 */
+(NSString *)weekConverByIday:(NSInteger )iday{
    switch (iday) {
        case 1:
        {
            return [ASLocalizeConfig localizedString:@"周一"];
        }
            break;
        case 2:
        {
            return [ASLocalizeConfig localizedString:@"周二"];
        }
            break;
        case 3:
        {
            return [ASLocalizeConfig localizedString:@"周三"];
        }
            break;
        case 4:
        {
            return [ASLocalizeConfig localizedString:@"周四"];
        }
            break;
        case 5:
        {
            return [ASLocalizeConfig localizedString:@"周五"];
        }
            break;
        case 6:
        {
            return [ASLocalizeConfig localizedString:@"周六"];
        }
            break;
        case 0:
        {
            return [ASLocalizeConfig localizedString:@"周日"];
        }
            break;
        default:
            return nil;
            break;
    }
}

@end
