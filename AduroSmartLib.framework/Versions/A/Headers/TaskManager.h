//
//  TaskManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/6.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"
@class AduroTask;

typedef void(^AllTaskBlock)(AduroTask *task);
typedef void(^AddAndEditTaskReturnBlock)(NSInteger taskID,AduroSmartReturnCode code);
typedef void(^TaskCallbackBlock) (AduroTask *task,AduroSmartReturnCode code);


@interface TaskManager : NSObject
+ (TaskManager *)sharedManager;
/**
 *  @author xingman.yi, 16-07-06 15:07:59
 *
 *  @brief 添加任务到网关
 *
 *  @param task              任务
 *  @param completionHandler 结果
 */
-(void)addTask:(AduroTask *)task completionHandler:(AddAndEditTaskReturnBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-06 15:07:27
 *
 *  @brief 从网关获取所有任务
 *
 *  @param tasks 任务列表
 */
-(void)getAllTasks:(AllTaskBlock)tasks;

/**
 *  @author xingman.yi, 16-07-06 15:07:37
 *
 *  @brief 更新任务到网关
 *
 *  @param task              任务
 *  @param completionHandler 结果
 */
-(void)updateTask:(AduroTask*)task completionHandler:(AddAndEditTaskReturnBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-06 15:07:01
 *
 *  @brief 从网关删除任务
 *
 *  @param task              任务
 *  @param completionHandler 结果
 */
-(void)deleteTask:(AduroTask*)task completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-12 11:07:03
 *
 *  @brief 任务执行后的回调
 *
 *  @param taskCallback 回调
 */
-(void)taskCallback:(TaskCallbackBlock)taskCallback;

/**
 *  @author xingman.yi, 16-08-04 15:08:55
 *
 *  @brief 更改任务的名称
 *
 *  @param task              任务
 *  @param completionHandler 结果
 */
-(void)changeNameWithTask:(AduroTask*)task completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-08-15 21:08:52
 *
 *  @brief 是否启用任务
 *
 *  @param task   任务
 *  @param enable 是否启用
 */
-(void)task:(AduroTask *)task enable:(BOOL )enable;

/**
 *  @author xingman.yi, 16-08-31 11:08:04
 *
 *  @brief 获取单个任务
 *
 *  @param taskID 任务编号
 */
-(void)getTaskWithTaskID:(NSInteger)taskID;

@end
