//
//  ASGetwayManageCell.m
//  AduroSmart
//
//  Created by MacBook on 16/9/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayManageCell.h"
#import "ASUserDefault.h"
#import "AppDelegate.h"
@interface ASGetwayManageCell (){
    UILabel *_gatewayNameLb;
    UILabel *_gatewayDetailLb;
   
    UIImageView *_gatewayImageView;  //网关的图标
    AduroGateway *_aduroGatewayInfo;
    UIView *_cellView;  //内容视图
    UIButton *_stateBtn;
//    BOOL isconnect;
}
-(void)getCellView;
@end


@implementation ASGetwayManageCell

@synthesize aduroGatewayInfo = _aduroGatewayInfo;
-(AduroGateway *)aduroGatewayInfo{
    return _aduroGatewayInfo;
}

-(void)setAduroGatewayInfo:(AduroGateway *)aduroGatewayInfo{
    if (_aduroGatewayInfo != aduroGatewayInfo) {
        _aduroGatewayInfo = nil;
        _aduroGatewayInfo = aduroGatewayInfo;
 
        [_gatewayImageView setImage:[UIImage imageNamed:@"gateway_set"]];
        [_gatewayNameLb setText:[NSString stringWithFormat:@"ZigBee Bridge"]];
        [_gatewayDetailLb setText:aduroGatewayInfo.gatewayID];
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (delegate.isConnect && [_aduroGatewayInfo.gatewayID isEqualToString:[ASUserDefault loadGatewayIDCache]]) {  //有网关连接，并且此网关是缓存的id的那个网关，则显示对勾
            [_stateBtn setBackgroundImage:[UIImage imageNamed:@"zigbee_green"] forState:UIControlStateNormal];
            
        }
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}


-(void)getCellView{
    _cellView = [[UIView alloc] init];
    [self.contentView addSubview:_cellView];
    //    _cellView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [_cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASGetwayManageCell getCellHeight]));
    }];
    
    //网关图标
    _gatewayImageView = [UIImageView new];
    [_cellView addSubview:_gatewayImageView];
    [_gatewayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.leading.equalTo(_cellView.mas_leading).offset(20); //首部
        make.height.equalTo(@(60));
        make.width.equalTo(_gatewayImageView.mas_height);
    }];
    //箭头
    UIImageView *arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = [UIImage imageNamed:@"arrow"];
    [_cellView addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.trailing.equalTo(_cellView.mas_trailing).offset(-10);
        make.height.equalTo(@(25));
        make.width.equalTo(arrowImgView.mas_height);
    }];
    
    UIButton *detailBtn = [UIButton new];
    [_cellView addSubview:detailBtn];
    [detailBtn setBackgroundImage:[UIImage imageNamed:@"zigbee_help"] forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(showGatewayDetail) forControlEvents:UIControlEventTouchUpInside];
    [detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.trailing.equalTo(arrowImgView.mas_leading).offset(-5);
        make.height.equalTo(@(25));
        make.width.equalTo(detailBtn.mas_height);
    }];
    
    _stateBtn = [UIButton new];
    [_cellView addSubview:_stateBtn];    
    [_stateBtn setBackgroundImage:[UIImage imageNamed:@"zigbee_gray"] forState:UIControlStateNormal];
//    if (isconnect) {
//        [_stateBtn setBackgroundImage:[UIImage imageNamed:@"zigbee_green"] forState:UIControlStateNormal];
//    }
    [_stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.trailing.equalTo(detailBtn.mas_leading).offset(-10);
        make.height.equalTo(@(26));
        make.width.equalTo(_stateBtn.mas_height);
    }];
    
    //设备名称
    _gatewayNameLb = [[UILabel alloc]init];
    [_gatewayNameLb setFont:[UIFont systemFontOfSize:16]];
    [_cellView addSubview:_gatewayNameLb];
    [_gatewayNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_gatewayImageView.mas_top);
        make.leading.equalTo(_gatewayImageView.mas_trailing).offset(10);
        make.trailing.equalTo(_stateBtn.mas_leading);
        make.bottom.equalTo(_gatewayImageView.mas_centerY);
    }];
    
    _gatewayDetailLb = [[UILabel alloc] init];
    [_gatewayDetailLb setFont:[UIFont systemFontOfSize:14]];
    [_gatewayDetailLb setTextColor:[UIColor lightGrayColor]];
    [_cellView addSubview:_gatewayDetailLb];
    [_gatewayDetailLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_gatewayNameLb.mas_bottom);
        make.leading.equalTo(_gatewayNameLb.mas_leading);
        make.trailing.equalTo(_gatewayNameLb.mas_trailing);
        make.bottom.equalTo(_gatewayImageView.mas_bottom);
    }];
    
//    //设备详情按钮
//    _deviceShowDetailBtn = [[UIButton alloc]init];
//    [_deviceShowDetailBtn addTarget:self action:@selector(showDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_cellView addSubview:_deviceShowDetailBtn];
//    [_deviceShowDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_cellView.mas_top);
//        make.leading.equalTo(_cellView.mas_leading);
//        make.trailing.equalTo(_deviceSwitchBtn.mas_leading);
//        make.bottom.equalTo(_cellView.mas_bottom);
//    }];
    //cell分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_cellView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_cellView.mas_leading).offset(20);
        make.trailing.equalTo(_cellView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(_cellView.mas_bottom);
    }];
    
}

-(void)showGatewayDetail{
    if ([self.delegate respondsToSelector:@selector(gatewayShowDetailWithAduroGateway:)]) {        
        [self.delegate gatewayShowDetailWithAduroGateway:_aduroGatewayInfo];
    }
}

+(CGFloat)getCellHeight{
    return 70.f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
