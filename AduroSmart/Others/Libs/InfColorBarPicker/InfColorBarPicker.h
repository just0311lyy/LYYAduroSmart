//==============================================================================
//
//  InfColorSquarePicker.h
//  InfColorPicker
//
//  Created by Troy Gaul on 8/9/10.
//


#import <UIKit/UIKit.h>
#import "HSV.h"

@protocol KZColorBarChangeDelegate <NSObject>

-(void)barColorChange:(UIColor *)color;
-(void)barHSVChange:(HSVType )hsv;
-(void)barColorTemperature:(CGFloat )colorTemperature;

@end

@interface InfColorBarView : UIImageView

@property (nonatomic) float hue;

@end



@interface InfColorBarPicker : UIControl
@property (nonatomic) HSVType currentHSV;
@property (nonatomic) float hue;
@property (nonatomic) CGPoint value;
@property (nonatomic) CGPoint HSValue;
@property (nonatomic,assign) id<KZColorBarChangeDelegate> delegate;
-(void)setHiddenIndicator:(BOOL)hidden;
@end

