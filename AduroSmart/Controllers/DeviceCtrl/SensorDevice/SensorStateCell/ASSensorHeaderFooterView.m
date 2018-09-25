//
//  ASSensorHeaderFooterView.m
//  AduroSmart
//
//  Created by MacBook on 16/8/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSensorHeaderFooterView.h"

@interface ASSensorHeaderFooterView ()
@property (nonatomic, strong) UIButton *bgBtn;

@end

@implementation ASSensorHeaderFooterView

static NSString *headerViewIdentifier = @"headerView";
+(instancetype)headerViewWithTableView:(UITableView *)tableView{
    ASSensorHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
    if (headerView == nil) {
        headerView = [[ASSensorHeaderFooterView alloc] initWithReuseIdentifier:headerViewIdentifier];
    }
    return headerView;
}

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]){
  
        //1、添加背景的btn
        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:bgBtn];
        
        //对bgBtn添加背景
//        UIImage *image = [[UIImage imageNamed:@"buddy_header_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 44, 1) resizingMode:UIImageResizingModeStretch];
//        UIImage *highLightedImage = [[UIImage imageNamed:@"buddy_header_bg_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 44, 1) resizingMode:UIImageResizingModeStretch];
//        [bgBtn setBackgroundImage:image forState:UIControlStateNormal];
//        [bgBtn setBackgroundImage:highLightedImage forState:UIControlStateHighlighted];
        //设置字体颜色
        [bgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //设置图片
        //        [bgBtn setImage:[UIImage imageNamed:@"buddy_header_arrow"] forState:UIControlStateNormal];
        //添加事件监听
        [bgBtn addTarget:self action:@selector(bgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置内容的显示
        bgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        //设置内容的偏移量
        bgBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        //设置标题的偏移量
        bgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
        //设置bgBtn的图片视图的内容模式
        bgBtn.imageView.contentMode = UIViewContentModeCenter;
        bgBtn.imageView.clipsToBounds = NO;
        
        _bgBtn = bgBtn;
        
        //2.添加图片
        UIImageView *leftImgView = [[UIImageView alloc] init];
        [self addSubview:leftImgView];
        _sensorImgView = leftImgView;
        
        
    }
    return self;
}

//子视图布局
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置bgBtn的frame
    _bgBtn.frame = self.bounds;
    _sensorImgView.frame =CGRectMake(20,(self.bounds.size.height - 50)/2, 50, 50);
}

-(void)setSensorName:(NSString *)sensorName{
    if (_sensorName != sensorName) {
        _sensorName = sensorName;
    }
    [_bgBtn setTitle:_sensorName forState:UIControlStateNormal];
    
}


-(void)bgBtnClick:(UIButton *)sender{
    
    [_delegate showOrRowStateWith:_index];
    
    if (_headerViewClick) {
        _headerViewClick();
    }
    
    NSLog(@"点击了传感器名");
    
}

+(CGFloat)getHeaderCellHeight{
    return 60;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
