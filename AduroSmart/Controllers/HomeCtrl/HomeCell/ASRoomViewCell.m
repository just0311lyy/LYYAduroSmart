//
//  ASRoomViewCell.m
//  AduroSmart
//
//  Created by MacBook on 2017/1/3.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import "ASRoomViewCell.h"

@implementation ASRoomViewCell



-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        
        self.backgroundColor = [UIColor clearColor];
        self.homeTypeImgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 115)/2,(frame.size.height-115)/2, 115, 115)];
        [self addSubview:self.homeTypeImgView];
        
        
    }
    return self;
}

@end
