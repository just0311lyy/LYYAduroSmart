//==============================================================================
//
//  InfColorSquarePicker.h
//  InfColorPicker
//
//  Created by Troy Gaul on 8/9/10.
//


#import <UIKit/UIKit.h>
#import "HSV.h"

@protocol KZColorPickerColorChangeDelegate <NSObject>

-(void)pickerColorChange:(UIColor *)color;
-(void)pickerHSVChange:(HSVType )hsv;

@end

@interface InfColorSquareView : UIImageView

@property (nonatomic) float hue;

@end



@interface InfColorSquarePicker : UIControl
@property (nonatomic) HSVType currentHSV;
@property (nonatomic) float hue;
@property (nonatomic) CGPoint value;
@property (nonatomic) CGPoint HSValue;
@property (nonatomic,assign) id<KZColorPickerColorChangeDelegate> delegate;
-(void)setHiddenIndicator:(BOOL)hidden;
@property (nonatomic) BOOL isCustomeImage;
-(void)setCustomeImage:(UIImage *)image;
-(void)setSenceImage:(UIImage *)image;
-(void)setNewSenceImage:(UIImage *)image;
@end

