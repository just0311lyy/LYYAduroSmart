//
//  ASDataBaseOperation.m
//  AduroSmart
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDataBaseOperation.h"
#import "FMDatabase.h"
#import "ASGlobalDataObject.h"

#import "MyTool.h"
@interface ASDataBaseOperation ()
{
    FMDatabase *dataBase;
}
@end

@implementation ASDataBaseOperation

-(BOOL)openDatabase{
    /*根据路径创建数据库和表*/
    NSArray * arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [arr objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"sunnyDatabase05.db"];
    dataBase = [FMDatabase databaseWithPath:path];
    [self createTable];
    return YES;
}
/** 创建所有的数据库表 */
-(void)createTable{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return;
    }
    //sensor数据存储
    NSMutableString *strSensorDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists sensorData_info_table("];
    [strSensorDataSql appendString:@"sensorSortNumber INTEGER PRIMARY KEY AUTOINCREMENT,"];
    [strSensorDataSql appendString:@"sensorID TEXT(100),"];
    [strSensorDataSql appendString:@"sensorData TEXT(100),"];
    [strSensorDataSql appendString:@"sensorDataTime TEXT(100),"];
    [strSensorDataSql appendString:@"sensorPower int DEFAULT 0)"];
    [dataBase executeUpdate:strSensorDataSql];
   
    NSMutableString *strDeviceDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists deviceData_info_table("];
    [strDeviceDataSql appendString:@"deviceSortNumber INTEGER PRIMARY KEY   AUTOINCREMENT,"];
    [strDeviceDataSql appendString:@"gatewayID TEXT(100),"];
    [strDeviceDataSql appendString:@"deviceName TEXT(100),"];
    [strDeviceDataSql appendString:@"deviceNetState int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceSwitchState int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightLevel int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightHue int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightSat int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightX int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightY int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceLightColorTemperature int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceID TEXT(100),"];
    [strDeviceDataSql appendString:@"deviceTypeID int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceType TEXT(100),"];
    [strDeviceDataSql appendString:@"deviceSensorData int DEFAULT 0,"];
//    [strDeviceDataSql appendString:@"deviceClusterIdSet TEXT(100),"];
    [strDeviceDataSql appendString:@"deviceAttribID int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"deviceZoneType int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"shortAdr int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"endPoint int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"MAIN_ENDPOINT int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"ProfileId int DEFAULT 0,"];
    [strDeviceDataSql appendString:@"IEEE int DEFAULT 0)"];
    [dataBase executeUpdate:strDeviceDataSql];
    
    //房间数据存储
    NSMutableString *strRoomDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists roomData_info_table("];
    [strRoomDataSql appendString:@"roomSortNumber INTEGER PRIMARY KEY AUTOINCREMENT,"];
    [strRoomDataSql appendString:@"gatewayID TEXT(100),"];
    [strRoomDataSql appendString:@"groupID int DEFAULT 0,"];
    [strRoomDataSql appendString:@"groupType int DEFAULT 0,"];
    [strRoomDataSql appendString:@"groupName TEXT(100),"];
    [strRoomDataSql appendString:@"groupCoverPath TEXT(100),"];
    [strRoomDataSql appendString:@"groupSubDeviceIDArrayStr TEXT(100))"];
    [dataBase executeUpdate:strRoomDataSql];
    
    //场景数据存储
    NSMutableString *strSceneDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists sceneData_info_table("];
    [strSceneDataSql appendString:@"sceneSortNumber INTEGER PRIMARY KEY AUTOINCREMENT,"];
    [strSceneDataSql appendString:@"gatewayID TEXT(100),"];
    [strSceneDataSql appendString:@"sceneID int DEFAULT 0,"];
    [strSceneDataSql appendString:@"sceneName TEXT(100),"];
    [strSceneDataSql appendString:@"groupID int DEFAULT 0,"];
    [strSceneDataSql appendString:@"sceneIconPath TEXT(100),"];
    [strSceneDataSql appendString:@"sceneSubDeviceIDArrayStr TEXT(100))"];
    [dataBase executeUpdate:strSceneDataSql];
    
    //任务数据存储
    NSMutableString *strTaskDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists tasksData_info_table("];
    [strTaskDataSql appendString:@"taskSortNumber INTEGER PRIMARY KEY AUTOINCREMENT,"];
    [strTaskDataSql appendString:@"gatewayID TEXT(100),"];
    [strTaskDataSql appendString:@"taskID int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskName TEXT(100),"];
    [strTaskDataSql appendString:@"taskType int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskConditionHour int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskConditionMinute int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskConditionSecond int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskConditionWeek int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskConditionDeviceStr TEXT(100),"];
    [strTaskDataSql appendString:@"taskConditionDeviceAction int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskTriggeredDeviceStr TEXT(100),"];
    [strTaskDataSql appendString:@"taskTriggeredSceneInt int DEFAULT 0,"];
    [strTaskDataSql appendString:@"taskEnableStr TEXT(100))"];
    [dataBase executeUpdate:strTaskDataSql];
//    //存储任务的设备属性
//    NSMutableString *strDeviceOfTaskDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists deviceOfTaskData_info_table("];
//    [strDeviceOfTaskDataSql appendString:@"deviceSortNumber INTEGER PRIMARY KEY   AUTOINCREMENT,"];
//    [strDeviceOfTaskDataSql appendString:@"taskID int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceName TEXT(100),"];
//    [strDeviceOfTaskDataSql appendString:@"deviceNetState int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceSwitchState int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightLevel int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightHue int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightSat int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightX int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightY int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceLightColorTemperature int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceID TEXT(100),"];
//    [strDeviceOfTaskDataSql appendString:@"deviceTypeID int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceType TEXT(100),"];
//    [strDeviceOfTaskDataSql appendString:@"deviceSensorData int DEFAULT 0,"];
//    //    [strDeviceDataSql appendString:@"deviceClusterIdSet TEXT(100),"];
//    [strDeviceOfTaskDataSql appendString:@"deviceAttribID int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"deviceZoneType int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"shortAdr int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"endPoint int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"MAIN_ENDPOINT int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"ProfileId int DEFAULT 0,"];
//    [strDeviceOfTaskDataSql appendString:@"IEEE int DEFAULT 0)"];
//    [dataBase executeUpdate:strDeviceOfTaskDataSql];
    
    //网关数据存储
    NSMutableString *strGatewayDataSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists gatewayData_info_table("];
    [strGatewayDataSql appendString:@"gatewaySortNumber INTEGER PRIMARY KEY AUTOINCREMENT,"];
    [strGatewayDataSql appendString:@"gatewayName TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayID TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewaySoftwareVersion TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayHardwareVersion TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayIPv4Address TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayDatetimeStr TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayTimeZone int DEFAULT 0,"];
    [strGatewayDataSql appendString:@"gatewaySecurityKey TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayGatewayType TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayServerDomain TEXT(100),"];
    [strGatewayDataSql appendString:@"gatewayToAppNetChannelType int DEFAULT 0)"];
    [dataBase executeUpdate:strGatewayDataSql];
    
    //推送通知
    NSMutableString *strPushnotiSql = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists pushnoti_msg_table("];
    [strPushnotiSql appendString:@"pushNotiID TEXT(100) PRIMARY KEY NOT NULL,"];
    [strPushnotiSql appendString:@"pushNotiURL TEXT(100) DEFAULT NULL,"];
    [strPushnotiSql appendString:@"pushNotiTitle TEXT(100) DEFAULT NULL,"];
    [strPushnotiSql appendString:@"pushNoteReceiveDate TEXT(100) DEFAULT NULL,"];
    [strPushnotiSql appendString:@"pushNotiIsRead TEXT(100) DEFAULT 'NO')"];
    [dataBase executeUpdate:strPushnotiSql];
}

+(ASDataBaseOperation *)sharedManager{
    static ASDataBaseOperation *sharedDatabaseManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDatabaseManagerInstance = [[self alloc] init];
    });
    return sharedDatabaseManagerInstance;
    
    
}

-(BOOL)excuteSqlString:(NSString *)sqlString{
    
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    return [dataBase executeUpdate:sqlString];
 
}

#pragma mark - 传感器数据相关
/** 保存传感器数据 是否保存成功 */
-(BOOL)saveSensorData:(ASSensorDataObject *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            NSString *insertSqlString = [NSString stringWithFormat:@"insert into sensorData_info_table(sensorID,sensorData,sensorDataTime,sensorPower) values('%@','%@','%@',%d)",model.sensorID,model.sensorData,model.sensorDataTime,(int)model.sensorPower];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing sensor data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}

/** 查询传感器数据存相关信息 返回的传感器数据存储对象数组 */
-(NSArray *)selectSensorData{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from sensorData_info_table order by  sensorSortNumber desc";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        ASSensorDataObject *model = [[ASSensorDataObject alloc]init];
        model.sensorID = [selectResult stringForColumn:@"sensorID"];
        model.sensorData = [selectResult stringForColumn:@"sensorData"];
        model.sensorDataTime = [selectResult stringForColumn:@"sensorDataTime"];
        model.sensorPower = [selectResult intForColumn:@"sensorPower"];
        [dataArray addObject:model];
    }
    return dataArray;
}

/** 通过设备的id去删除本地传感器数据  *   是否删除成功 */
-(BOOL)deleteSensorWithID:(NSString *)deviceId{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM sensorData_info_table WHERE sensorID = '%@'",deviceId];
    return [dataBase executeUpdate:sqlString];
}
#pragma mark -设备数据相关
/** 保存设备数据 是否保存成功 */
-(BOOL)saveDeviceData:(AduroDevice *)model withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            //判断设备是否存在
            NSString *selectDeviceSql = [[NSString alloc]initWithFormat:@"select deviceID from deviceData_info_table where deviceID = '%@'",model.deviceID];
            FMResultSet *selectDeviceResult = [dataBase executeQuery:selectDeviceSql];
            BOOL isExistDevice = [selectDeviceResult next];
            if (isExistDevice) {
                return isInsertResult;
            }
            NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into deviceData_info_table(gatewayID,deviceName,deviceNetState,deviceSwitchState,deviceLightLevel,deviceLightHue,deviceLightSat,deviceLightX,deviceLightY,deviceLightColorTemperature,deviceID,deviceTypeID,deviceType,deviceSensorData,deviceAttribID,deviceZoneType,shortAdr,endPoint,MAIN_ENDPOINT,ProfileId,IEEE) values('%@','%@',%d,%d,%d,%d,%d,%d,%d,%d,'%@',%d,'%@',%d,%d,%d,%d,%d,%d,%d,%d)",gatewayID,model.deviceName,model.deviceNetState,model.deviceSwitchState,model.deviceLightLevel,model.deviceLightHue,model.deviceLightSat,model.deviceLightX,model.deviceLightY,model.deviceLightColorTemperature,model.deviceID,model.deviceTypeID,model.deviceType,model.deviceSensorData,model.deviceAttribID,model.deviceZoneType,model.shortAdr,model.endPoint,model.MAIN_ENDPOINT,model.ProfileId,model.IEEE];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing device data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}
/** 通过id更新某个设备名称 */
-(BOOL)updateDeviceNameData:(NSString *)deviceName WithID:(NSString *)deviceID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update deviceData_info_table set deviceName ='%@' where deviceID ='%@'",deviceName,deviceID];
    return [self excuteSqlString:updatePowerSql];
}
/** 通过id更新某个设备亮度 */
-(BOOL)updateDeviceLightLevelData:(NSInteger)deviceLight WithID:(NSString *)deviceID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update deviceData_info_table set deviceLightLevel ='%d' where deviceID ='%@'",deviceLight,deviceID];
    return [self excuteSqlString:updatePowerSql];
}
/** 通过id更新某个设备开关 */
-(BOOL)updateDeviceSwitchData:(NSInteger)onOff WithID:(NSString *)deviceID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update deviceData_info_table set deviceSwitchState ='%d' where deviceID ='%@'",onOff,deviceID];
    return [self excuteSqlString:updatePowerSql];
}
/** 查询设备存储相关信息 返回的设备数据存储对象数组 */
-(NSArray *)selectDeviceDataWithGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from deviceData_info_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        NSString *gatewayIDStr = [selectResult stringForColumn:@"gatewayID"];
        if ([gatewayIDStr isEqualToString:gatewayID]) {
            AduroDevice *model = [[AduroDevice alloc]init];
            model.deviceName = [selectResult stringForColumn:@"deviceName"];
            model.deviceNetState = [selectResult intForColumn:@"deviceNetState"];
            model.deviceSwitchState = [selectResult intForColumn:@"deviceSwitchState"];
            model.deviceLightLevel = [selectResult intForColumn:@"deviceLightLevel"];
            model.deviceLightHue = [selectResult intForColumn:@"deviceLightHue"];
            model.deviceLightSat = [selectResult intForColumn:@"deviceLightSat"];
            model.deviceLightX = [selectResult intForColumn:@"deviceLightX"];
            model.deviceLightY = [selectResult intForColumn:@"deviceLightY"];
            model.deviceLightColorTemperature = [selectResult intForColumn:@"deviceLightColorTemperature"];
            model.deviceID = [selectResult stringForColumn:@"deviceID"];
            model.deviceTypeID = [selectResult intForColumn:@"deviceTypeID"];
            model.deviceType = [selectResult stringForColumn:@"deviceType"];
            model.deviceSensorData = [selectResult intForColumn:@"deviceSensorData"];
    //        model.deviceClusterId = [selectResult intForColumn:@"deviceClusterId"];
            model.deviceAttribID = [selectResult intForColumn:@"deviceAttribID"];
            model.deviceZoneType = [selectResult intForColumn:@"deviceZoneType"];
            model.shortAdr = [selectResult intForColumn:@"shortAdr"];
            model.endPoint = [selectResult intForColumn:@"endPoint"];
            model.MAIN_ENDPOINT = [selectResult intForColumn:@"MAIN_ENDPOINT"];
            model.ProfileId = [selectResult intForColumn:@"ProfileId"];
            model.IEEE = [selectResult intForColumn:@"IEEE"];
        
            [dataArray addObject:model];
        }
    }
    return dataArray;
}

/** 通过设备的id去删除本地数据  *   是否删除成功 */
-(BOOL)deleteDeviceWithID:(NSString *)deviceId{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM deviceData_info_table WHERE deviceID='%@'",deviceId];
    return [dataBase executeUpdate:sqlString];
}
/** 删除device表中的所有数据 是否成功 */
-(BOOL)deleteAllDevices
{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM deviceData_info_table"];
    return [dataBase executeUpdate:sqlString];
}
/** 更新文件数据，是否更新成功 */
-(BOOL)updateDeviceInfo:(AduroDevice *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    if (model.deviceID) {
        return NO;  //设备id不做更改
    }
    NSMutableString *updatePowerSql = [NSMutableString stringWithFormat:@"update deviceData_info_table set "];
    if (model.deviceName) {
        [updatePowerSql appendFormat:@"deviceName = '%@' ",model.deviceName];
    }
    if (model.deviceNetState) {
        [updatePowerSql appendFormat:@"deviceNetState = '%d' ",model.deviceNetState];
    }
    if (model.deviceSwitchState) {
        [updatePowerSql appendFormat:@"deviceSwitchState = '%d' ",model.deviceSwitchState];
    }
    if (model.deviceLightLevel) {
        [updatePowerSql appendFormat:@"deviceLightLevel = '%d' ",model.deviceLightLevel];
    }
    if (model.deviceLightHue) {
        [updatePowerSql appendFormat:@"deviceLightHue = '%d' ",model.deviceLightHue];
    }
    if (model.deviceLightSat) {
        [updatePowerSql appendFormat:@"deviceLightSat = '%d' ",model.deviceLightSat];
    }
    if (model.deviceLightX) {
        [updatePowerSql appendFormat:@"deviceLightX = '%d' ",model.deviceLightX];
    }
    if (model.deviceLightY) {
        [updatePowerSql appendFormat:@"deviceLightY = '%d' ",model.deviceLightY];
    }
    if (model.deviceLightColorTemperature) {
        [updatePowerSql appendFormat:@"deviceLightColorTemperature = '%d' ",model.deviceLightColorTemperature];
    }
    if (model.deviceID) {
        [updatePowerSql appendFormat:@" where deviceID = '%@'",model.deviceID];
    }
    DDLogDebug(@"updateDeviceInfo sql = %@",updatePowerSql);
    return [self excuteSqlString:updatePowerSql];
    
}

/** 查询设备数据存相关信息 返回的设备数据行数 */
-(NSInteger )selectDeviceSortNumberWithDeviceID:(NSString *)deviceID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return 0;
    }
    NSInteger deviceSortNumber = 0;
    NSString *sqlString = [NSString stringWithFormat:@"select deviceSortNumber from deviceData_info_table where deviceID=%@",deviceID];
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    while ([selectResult next]) {
        deviceSortNumber = [selectResult intForColumn:@"deviceSortNumber"];
    }
    return deviceSortNumber;
}

#pragma mark - 房间数据相关
/** 保存房间数据是否成功 */
-(BOOL)saveRoomData:(AduroGroup *)model withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            //1.先判断网关id是否存在
            NSString *selectGroupSql = [[NSString alloc]initWithFormat:@"select * from roomData_info_table where gatewayID = '%@' and groupID = %ld",gatewayID,model.groupID];
            FMResultSet *selectGroupResult = [dataBase executeQuery:selectGroupSql];
            BOOL isExistGroup = [selectGroupResult next];
            if (isExistGroup) {
                return isInsertResult;
            }
            NSString *subDeviceOfGroupStr = @"";
            if (model.groupSubDeviceIDArray.count>0) {
                for (int i=0; i<model.groupSubDeviceIDArray.count; i++) {
                    subDeviceOfGroupStr = [NSString stringWithFormat:@"%@,%@",subDeviceOfGroupStr,model.groupSubDeviceIDArray[i]];
                }
            }
            NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into roomData_info_table(gatewayID,groupID,groupType,groupName,groupCoverPath,groupSubDeviceIDArrayStr) values('%@',%d,%d,'%@','%@','%@')",gatewayID,model.groupID,model.groupType,model.groupName,model.groupCoverPath,subDeviceOfGroupStr];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing device data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}

/** 通过id更新某个房间名称 */
-(BOOL)updateRoomNameData:(NSString *)groupName WithID:(NSInteger)groupID withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update roomData_info_table set groupName ='%@' where groupID ='%d' and gatewayID = '%@'",groupName,groupID,gatewayID];
    return [self excuteSqlString:updatePowerSql];
}

/** 查询房间对象数组 */
-(NSArray *)selectRoomDataWithGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from roomData_info_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        NSString *gatewayIDStr = [selectResult stringForColumn:@"gatewayID"];
        if ([gatewayIDStr isEqualToString:gatewayID]) {
            AduroGroup *model = [[AduroGroup alloc]init];
            model.groupID = [selectResult intForColumn:@"groupID"];
            model.groupType = [selectResult intForColumn:@"groupType"];
            model.groupName = [selectResult stringForColumn:@"groupName"];
            model.groupCoverPath = [selectResult stringForColumn:@"groupCoverPath"];
            NSString *groupSubDeviceIDArrayStr = [selectResult stringForColumn:@"groupSubDeviceIDArrayStr"];
            NSArray *array = [groupSubDeviceIDArrayStr componentsSeparatedByString:@","];
            model.groupSubDeviceIDArray = [[NSMutableArray alloc] initWithArray:array];
            [dataArray addObject:model];
        }
    }
    return dataArray;
}

/** 通过group的id去删除单条本地数据 是否成功 */
-(BOOL)deleteRoomWithID:(NSInteger)groupId withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM roomData_info_table WHERE groupID = '%d' and gatewayID = '%@'",groupId,gatewayID];
    return [dataBase executeUpdate:sqlString];
}

/** 删除group表中的所有数据 是否成功 */
-(BOOL)deleteAllRooms
{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM roomData_info_table"];
    return [dataBase executeUpdate:sqlString];
}

/** 更新group数据，是否更新成功 */
-(BOOL)updateRoomInfo:(AduroGroup *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    if (model.groupID) {
        return NO;  //设备id不做更改
    }
    NSMutableString *updatePowerSql = [NSMutableString stringWithFormat:@"update deviceData_info_table set "];
    if (model.groupType) {
        [updatePowerSql appendFormat:@"groupType = '%d' ",model.groupType];
    }
    if (model.groupName) {
        [updatePowerSql appendFormat:@"groupName = '%@' ",model.groupName];
    }
    if (model.groupCoverPath) {
        [updatePowerSql appendFormat:@"groupCoverPath = '%@' ",model.groupCoverPath];
    }
    if (model.groupSubDeviceIDArray) {
        [updatePowerSql appendFormat:@"groupSubDeviceIDArray = '%@' ",model.groupSubDeviceIDArray];
    }
    if (model.groupID) {
        [updatePowerSql appendFormat:@" where groupID = '%d'",model.groupID];
    }
    DDLogDebug(@"updateRoomInfo sql = %@",updatePowerSql);
    return [self excuteSqlString:updatePowerSql];
}

#pragma mark - 场景数据相关
/** 保存场景数据是否保存成功 */
-(BOOL)saveSceneData:(AduroScene *)model withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            //判断场景是否存在
            NSString *selectSceneSql = [[NSString alloc]initWithFormat:@"select * from sceneData_info_table where sceneID = %d and gatewayID = '%@'",model.sceneID,gatewayID];
            FMResultSet *selectSceneResult = [dataBase executeQuery:selectSceneSql];
            BOOL isExistScene = [selectSceneResult next];
            if (isExistScene) {
                return isInsertResult;
            }
            NSString *subDeviceOfSceneStr = @"";
            if (model.sceneSubDeviceIDArray.count>0) {
                for (int i=0; i<model.sceneSubDeviceIDArray.count; i++) {
                    subDeviceOfSceneStr = [NSString stringWithFormat:@"%@,%@",subDeviceOfSceneStr,model.sceneSubDeviceIDArray[i]];
                }
            }
            
            NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into sceneData_info_table(gatewayID,sceneID,sceneName,groupID,sceneIconPath,sceneSubDeviceIDArrayStr) values('%@',%d,'%@',%d,'%@','%@')",gatewayID,model.sceneID,model.sceneName,model.groupID,model.sceneIconPath,subDeviceOfSceneStr];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing device data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}

/** 查询场景数据对象数组 */
-(NSArray *)selectSceneDataWithGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from sceneData_info_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        NSString *gatewayIDStr = [selectResult stringForColumn:@"gatewayID"];
        if ([gatewayIDStr isEqualToString:gatewayID]) {
            AduroScene *model = [[AduroScene alloc]init];
            model.sceneID = [selectResult intForColumn:@"sceneID"];
            model.sceneName = [selectResult stringForColumn:@"sceneName"];
            model.groupID = [selectResult intForColumn:@"groupID"];
            model.sceneIconPath = [selectResult stringForColumn:@"sceneIconPath"];
            NSString *sceneSubDeviceIDArrayStr = [selectResult stringForColumn:@"sceneSubDeviceIDArrayStr"];
            NSArray *array = [sceneSubDeviceIDArrayStr componentsSeparatedByString:@","];
            model.sceneSubDeviceIDArray = [[NSMutableArray alloc] initWithArray:array];
            [dataArray addObject:model];
        }
    }
    return dataArray;
}
/** 通过id更新某个场景名称 */
-(BOOL)updateSceneNameData:(NSString *)sceneName withID:(NSInteger)sceneID withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update sceneData_info_table set sceneName ='%@' where sceneID='%d' and gatewayID = '%@'",sceneName,sceneID,gatewayID];
    return [self excuteSqlString:updatePowerSql];
}
/** 通过scene的id去删除本地数据 是否删除成功 */
-(BOOL)deleteSceneWithID:(NSInteger)sceneID withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM sceneData_info_table WHERE sceneID='%d' and gatewayID = '%@'",sceneID,gatewayID];
    return [dataBase executeUpdate:sqlString];
}
/** 删除全部scene数据 是否删除成功 */
-(BOOL)deleteAllScenes{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM sceneData_info_table"];
    return [dataBase executeUpdate:sqlString];
}

/** 更新Scene数据，是否更新成功 */
-(BOOL)updateSceneInfo:(AduroScene *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    if (model.sceneID) {
        return NO;  //设备id不做更改
    }
    NSMutableString *updatePowerSql = [NSMutableString stringWithFormat:@"update sceneData_info_table set "];
    if (model.sceneName) {
        [updatePowerSql appendFormat:@"sceneName = '%@' ",model.sceneName];
    }
    if (model.groupID) {
        [updatePowerSql appendFormat:@"groupName = '%d' ",model.groupID];
    }
    if (model.sceneIconPath) {
        [updatePowerSql appendFormat:@"sceneIconPath = '%@' ",model.sceneIconPath];
    }
    if (model.sceneSubDeviceIDArray) {
        [updatePowerSql appendFormat:@"sceneSubDeviceIDArray = '%@' ",model.sceneSubDeviceIDArray];
    }
    if (model.sceneID) {
        [updatePowerSql appendFormat:@" where sceneID = '%d'",model.sceneID];
    }
    DDLogDebug(@"updateSceneInfo sql = %@",updatePowerSql);
    return [self excuteSqlString:updatePowerSql];
}

#pragma mark - 任务数据相关
/** 保存任务数据 是否保存成功 */
-(BOOL)saveTasksData:(AduroTask *)model withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            //判断场景是否存在
            NSString *selectTaskSql = [[NSString alloc]initWithFormat:@"select * from tasksData_info_table where taskID = %ld and gatewayID = '%@'",model.taskID,gatewayID];
            FMResultSet *selectTaskResult = [dataBase executeQuery:selectTaskSql];
            BOOL isExistTask = [selectTaskResult next];
            if (isExistTask) {
                return isInsertResult;
            }
            NSString *taskEnableStr = @"";
            if (model.taskEnable == YES) {
                taskEnableStr = @"YES";
            }else{
                taskEnableStr = @"NO";
            }
            NSString *insertSqlString = [[NSString alloc] initWithFormat:@"insert into tasksData_info_table(gatewayID,taskID,taskName,taskType,taskConditionHour,taskConditionMinute,taskConditionSecond,taskConditionWeek,taskConditionDeviceStr,taskConditionDeviceAction,taskTriggeredDeviceStr,taskTriggeredSceneInt,taskEnableStr) values('%@',%d,'%@',%d,%d,%d,%d,%d,'%@',%d,'%@',%d,'%@')",gatewayID,model.taskID,model.taskName,model.taskType,model.taskConditionHour,model.taskConditionMinute,model.taskConditionSecond,model.taskConditionWeek,model.taskConditionDevice.deviceID,model.taskConditionDeviceAction,model.taskTriggeredDevice.deviceID,model.taskTriggeredScene.sceneID,taskEnableStr];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing device data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}

/** 查询任务数据对象数组 */
-(NSArray *)selectTaskDataWithGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from tasksData_info_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        NSString *gatewayIDStr = [selectResult stringForColumn:@"gatewayID"];
        if ([gatewayIDStr isEqualToString:gatewayID]) {
            AduroTask *model = [[AduroTask alloc]init];
            model.taskID = [selectResult intForColumn:@"taskID"];
            model.taskName = [selectResult stringForColumn:@"taskName"];
            model.taskType = [selectResult intForColumn:@"taskType"];
            model.taskConditionHour = [selectResult intForColumn:@"taskConditionHour"];
            model.taskConditionMinute = [selectResult intForColumn:@"taskConditionMinute"];
            model.taskConditionSecond = [selectResult intForColumn:@"taskConditionSecond"];
            model.taskConditionWeek = [selectResult intForColumn:@"taskConditionWeek"];
            NSString *taskConditionDeviceStr = [selectResult stringForColumn:@"taskConditionDeviceStr"];
            if (_globalDeviceArray.count>0) {
                for (AduroDevice *myDevice in _globalDeviceArray) {
                    if ([myDevice.deviceID isEqualToString:taskConditionDeviceStr]) {
                        model.taskConditionDevice = myDevice;
                    }
    //                else{
    //                    model.taskConditionDevice = nil;
    //                }
                }
            }
            model.taskConditionDeviceAction = [selectResult intForColumn:@"taskConditionDeviceAction"];
            NSString *taskTriggeredDeviceStr = [selectResult stringForColumn:@"taskTriggeredDevice"];
            if (_globalDeviceArray.count>0) {
                for (AduroDevice *myDevice in _globalDeviceArray) {
                    if ([myDevice.deviceID isEqualToString:taskTriggeredDeviceStr]) {
                        model.taskTriggeredDevice = myDevice;
                    }
                    //                else{
                    //                    model.taskTriggeredDevice = nil;
                    //                }
                }
            }
            int taskTriggeredSceneInt = [selectResult intForColumn:@"taskTriggeredSceneInt"];
            if (_globalSceneArray.count>0) {
                for (AduroScene *myScene in _globalSceneArray) {
                    if (myScene.sceneID == taskTriggeredSceneInt) {
                        model.taskTriggeredScene = myScene;
                    }
                    //                else{
                    //                    model.taskTriggeredDevice = nil;
                    //                }
                }
            }
            NSString *taskEnableStr = [selectResult stringForColumn:@"taskEnable"];
            if ([taskEnableStr isEqualToString:@"YES"]) {
                model.taskEnable = YES;
            }else{
                model.taskEnable = NO;
            }
            [dataArray addObject:model];
        }
    }
    return dataArray;
}
/** 通过id更新某个任务名称 */
-(BOOL)updateTaskNameData:(NSString *)taskName withID:(NSInteger)taskID withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update tasksData_info_table set taskName ='%@' where taskID='%d' and gatewayID = '%@'",taskName,taskID,gatewayID];
    return [self excuteSqlString:updatePowerSql];
}
/** 通过task的id去删除本地数据 是否删除成功 */
-(BOOL)deleteTaskWithID:(NSInteger)taskId withGatewayid:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM tasksData_info_table WHERE taskID ='%d' and gatewayID = '%@'",taskId,gatewayID];
    return [dataBase executeUpdate:sqlString];
}

/** 删除全部task数据 是否删除成功 */
-(BOOL)deleteAllTasks{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM tasksData_info_table"];
    return [dataBase executeUpdate:sqlString];
}

#pragma mark - 网关数据处理
/** 保存网关数据是否保存成功 */
-(BOOL)saveGatewayData:(AduroGateway *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    BOOL isInsertResult = NO;
    if (model) {
        @try {
            //判断网关是否存在
            NSString *selectGatewaySql = [[NSString alloc]initWithFormat:@"select * from gatewayData_info_table where gatewayID = '%@'",model.gatewayID];
            FMResultSet *selectGatewayResult = [dataBase executeQuery:selectGatewaySql];
            BOOL isExistGateway = [selectGatewayResult next];
            if (isExistGateway) {
                return isInsertResult;
            }
            NSString *gatewayDatetimeStr = [self dateStringFromDate:model.gatewayDatetime];
            
            NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into gatewayData_info_table(gatewayName,gatewayID,gatewaySoftwareVersion,gatewayHardwareVersion,gatewayIPv4Address,gatewayDatetimeStr,gatewayTimeZone,gatewaySecurityKey,gatewayGatewayType,gatewayServerDomain,gatewayToAppNetChannelType) values('%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@',%d)",model.gatewayName,model.gatewayID,model.gatewaySoftwareVersion,model.gatewayHardwareVersion,model.gatewayIPv4Address,gatewayDatetimeStr,model.gatewayTimeZone,model.gatewaySecurityKey,model.gatewayGatewayType,model.gatewayServerDomain,model.gatewayToAppNetChannelType];
            isInsertResult = [self excuteSqlString:insertSqlString];
        } @catch (NSException *exception) {
            NSLog(@"saveing device data error %@",exception);
        } @finally {
            
        }
    }
    return isInsertResult;
}
/** 通过网关的id更新某个网关的版本号 */
-(BOOL)updateGatewayVersionData:(NSString *)softwareVersion WithID:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update gatewayData_info_table set gatewaySoftwareVersion ='%@' where gatewayID ='%@'",softwareVersion,gatewayID];
    return [self excuteSqlString:updatePowerSql];
}
/** 通过网关的id去删除本地数据 *   是否删除成功 */
-(BOOL)deleteGatewayWithID:(NSString *)gatewayID{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM gatewayData_info_table WHERE gatewayID='%@'",gatewayID];
    return [dataBase executeUpdate:sqlString];
}

/** 查询网关数据对象数组 */
-(NSArray *)selectGatewayData{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from gatewayData_info_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        AduroGateway *model = [[AduroGateway alloc]init];
        model.gatewayName = [selectResult stringForColumn:@"gatewayName"];
        model.gatewayID = [selectResult stringForColumn:@"gatewayID"];
        model.gatewaySoftwareVersion = [selectResult stringForColumn:@"gatewaySoftwareVersion"];
        model.gatewayHardwareVersion = [selectResult stringForColumn:@"gatewayHardwareVersion"];
        model.gatewayIPv4Address = [selectResult stringForColumn:@"gatewayIPv4Address"];
        model.gatewayDatetime = [self myDateFromString:[selectResult stringForColumn:@"gatewayDatetimeStr"]];
        model.gatewaySecurityKey = [selectResult stringForColumn:@"gatewaySecurityKey"];
        model.gatewayGatewayType = [selectResult stringForColumn:@"gatewayGatewayType"];
        model.gatewayServerDomain = [selectResult stringForColumn:@"gatewayServerDomain"];
        model.gatewayToAppNetChannelType = [selectResult intForColumn:@"gatewayToAppNetChannelType"];
        [dataArray addObject:model];
    }
    return dataArray;
}

#pragma mark - 推送通知相关
/* 保存推送过来的数据 * 推送消息数据 */
-(BOOL)savePushData:(ASPushNotiModel *)model{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    
    BOOL isInsertResult = NO;
    //判断是否已经存在，如果已经存在则插入，否则跳过
    NSString *selectDeviceSql = [[NSString alloc]initWithFormat:@"select pushNotiTitle from pushnoti_msg_table where pushNotiID = '%@'",model.pushNotiID];
    FMResultSet *selectDeviceResult = [dataBase executeQuery:selectDeviceSql];
    BOOL isExistDevice = [selectDeviceResult next];
    if (!isExistDevice) {
        NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into pushnoti_msg_table(pushNotiID,pushNotiTitle,pushNotiIsRead,pushNotiURL,pushNoteReceiveDate) values('%@','%@','%@','%@','%@')",model.pushNotiID,model.pushNotiTitle,model.pushNotiIsRead,model.pushNotiURL,[MyTool stringFromDate:model.pushNoteReceiveDate]];
        isInsertResult = [self excuteSqlString:insertSqlString];
    }
    return isInsertResult;
}
/** 查询本地存储的所有推送通知 */
-(NSArray *)selectAllPushMsgData{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from pushnoti_msg_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        ASPushNotiModel *model = [[ASPushNotiModel alloc]init];
        model.pushNotiID = [selectResult stringForColumn:@"pushNotiID"];
        model.pushNotiTitle = [selectResult stringForColumn:@"pushNotiTitle"];
        model.pushNotiURL = [selectResult stringForColumn:@"pushNotiURL"];
        model.pushNoteReceiveDate = [self myDateFromString:[selectResult stringForColumn:@"pushNoteReceiveDate"]];
        model.pushNotiIsRead = [selectResult stringForColumn:@"pushNotiIsRead"];
        [dataArray addObject:model];
    }
    return dataArray;
}
/** 查询本地存储的未阅读的通知数量 */
-(NSInteger)selectNoReadCount{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return 0;
    }
    NSString *sqlString = @"select count(*) as countnumber from pushnoti_msg_table WHERE pushNotiIsRead = 'NO'";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSInteger iCountNumber = 0;
    while ([selectResult next]) {
        iCountNumber = [selectResult intForColumn:@"countnumber"];
    }
    return iCountNumber;
}
/** 通过推送消息的id去删除本地数据 */
-(BOOL)deletePushMsgWithMsgID:(NSString *)msgid{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM pushnoti_msg_table WHERE pushNotiID='%@'",msgid];
    return [dataBase executeUpdate:sqlString];
}
/** 更新推送通知的阅读状态为已经阅读 */
-(BOOL)updatePushDataToReadWithPushMsgID:(NSString *)msgid{
    if (![dataBase open]) {
        DDLogDebug(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update pushnoti_msg_table set pushNotiIsRead='YES' where pushNotiID='%@'",msgid];
    return [self excuteSqlString:updatePowerSql];
}


/**
 *  从时间字符串转换为NSDate对象
 *
 *  @param dateString 时间字符串 2015-05-16 14:41:37
 *
 *  @return NSDate对象
 */
-(NSDate *)myDateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate = [dateFormatter dateFromString:dateString];
    return destDate;
}

/**
 *  从NSDate对象转换为时间字符串
 *
 *  @param dateString 时间字符串 2015-05-16 14:41:37
 *
 *  @return NSDate对象
 */
-(NSString *)dateStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}


@end
