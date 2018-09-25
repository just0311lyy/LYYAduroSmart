//
//  ASSensorDataObject.h
//  AduroSmart
//
//  Created by MacBook on 16/8/17.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASSensorDataObject : NSObject
@property (nonatomic) NSString *sensorID;
@property (nonatomic) NSString *sensorData;
@property (nonatomic) NSString *sensorDataTime;
@property (nonatomic) NSInteger sensorPower;
@end
