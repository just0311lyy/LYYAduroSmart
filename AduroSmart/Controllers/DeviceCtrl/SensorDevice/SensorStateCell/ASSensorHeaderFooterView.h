//
//  ASSensorHeaderFooterView.h
//  AduroSmart
//
//  Created by MacBook on 16/8/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASSensorHeaderFooterViewDelegate <NSObject>

-(void)showOrRowStateWith:(NSInteger)index;

@end

@interface ASSensorHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *sensorName;
@property (nonatomic, strong) UIImageView *sensorImgView;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) void (^headerViewClick)(void);

@property (nonatomic, assign) id<ASSensorHeaderFooterViewDelegate>delegate;
+(instancetype)headerViewWithTableView:(UITableView *)tableView;

+(CGFloat)getHeaderCellHeight;
@end
