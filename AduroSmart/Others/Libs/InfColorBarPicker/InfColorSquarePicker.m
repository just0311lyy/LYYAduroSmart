//
//  InfColorSquarePicker.m
//  InfColorPicker
//
//  Created by Troy Gaul on 8/9/10.
//


#import "InfColorSquarePicker.h"

#import "InfColorIndicatorView.h"
#import "InfHSBSupport.h"
#import "UIImage+ColorAtPixel.h"
#import <Masonry.h>



#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif



#define kContentInsetX 15
#define kContentInsetY 15

#define kIndicatorSize 30



@implementation InfColorSquareView



static CGImageRef createContentImage(int w,int h)
{
    float hsv[] = { 0.0f, 1.0f, 1.0f };
    return createHSVBarContentImage(InfComponentIndexHue, hsv,w,h);
}



- (void) drawRect: (CGRect) rect
{
    CGImageRef image = createContentImage(rect.size.width,rect.size.height);
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextDrawImage(context, [self bounds], image);
        
        CGImageRelease(image);
    }
}
- (void) updateContent
{
    float hsv[] = { 1.0f, 1.0f, 1.0f };
    CGImageRef image = createHSVBarContentImage(InfComponentIndexHue, hsv,self.frame.size.width,self.frame.size.height);
    self.image = [UIImage imageWithCGImage: image];
}

#pragma mark	Properties


- (void) setHue: (float) value
{
    return;
	if (value != _hue || self.image == nil) {
		_hue = value;
		
		[self updateContent];
	}
}



@end



@implementation InfColorSquarePicker {
	InfColorIndicatorView* indicator;
    InfColorSquareView *_infColorSquareView;
}

#pragma mark	Appearance

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _infColorSquareView = [[InfColorSquareView alloc]initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.height)];
        [_infColorSquareView setHue:0.6];
        [self addSubview:_infColorSquareView];
        if (indicator == nil) {
            CGRect indicatorRect = { CGPointZero, { kIndicatorSize, kIndicatorSize } };
            indicator = [[InfColorIndicatorView alloc] initWithFrame: indicatorRect];
            [self addSubview: indicator];
        }
    }
    return self;
}

- (void) setIndicatorColor
{
    
	if (indicator == nil)
    {
		return;
    }
	indicator.color = [UIColor colorWithHue: self.value.x
	                             saturation:1-self.value.y
	                             brightness:1.0f
	                                  alpha:1.0f];
}



- (NSString*) spokenValue
{
	return [NSString stringWithFormat: @"%d%% saturation, %d%% brightness", 
						(int) (self.value.x * 100), (int) (self.value.y * 100)];
}



- (void) layoutSubviews
{
	
	
	[self setIndicatorColor];
	
	CGFloat indicatorX = kContentInsetX + (self.value.x * (self.bounds.size.width - 2 * kContentInsetX));
	CGFloat indicatorY = self.bounds.size.height - kContentInsetY
					   - (self.value.y * (self.bounds.size.height - 2 * kContentInsetY));
	indicator.center = CGPointMake(indicatorX, indicatorY);
}


#pragma mark	Properties


- (void) setHue: (float) newValue
{
	if (newValue != _hue) {
		_hue = newValue;
		
		[self setIndicatorColor];
	}
}



- (void) setValue: (CGPoint) newValue
{
	if (!CGPointEqualToPoint(newValue, _value)) {
		_value = newValue;
		
		[self sendActionsForControlEvents: UIControlEventValueChanged];
		[self setNeedsLayout];
	}
}



#pragma mark	Tracking


- (void) trackIndicatorWithTouch: (UITouch*) touch
{
	CGRect bounds = self.bounds;
	
    UIColor *currentColor = [UIColor whiteColor];
    CGPoint touchValue;
    
    touchValue.x = ([touch locationInView: self].x - kContentInsetX)
    / (bounds.size.width - 2 * kContentInsetX);
    
    touchValue.y = ([touch locationInView: self].y /*- kContentInsetY*/)
    / (bounds.size.height - 2 * kContentInsetY);

    touchValue.x = pin(0.0f, touchValue.x, 1.0f);
    touchValue.y = 1.0f - pin(0.0f, touchValue.y, 1.0f);
    
    if (self.isCustomeImage) {
        CGPoint localValue = [touch locationInView:self];
        UIImage *customeImage = [self reSizeImage:_infColorSquareView.image toSize:_infColorSquareView.frame.size];
        currentColor = [customeImage colorAtPixel:localValue];
        CGFloat R, G, B;
        CGColorRef color = [currentColor CGColor];
        unsigned long numComponents = CGColorGetNumberOfComponents(color);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(color);
            R = components[0];
            G = components[1];
            B = components[2];
        }
        self.currentHSV = RGB_to_HSV(RGBTypeMake(R, G, B));
        indicator.center = localValue;
        indicator.color = currentColor;
    }else{
//        self.value = touchValue;
//        self.currentHSV = HSVTypeMake(self.value.x, 1-self.value.y, 1);
//        currentColor = [UIColor colorWithHue:self.currentHSV.h
//                                           saturation:self.currentHSV.s
//                                           brightness:self.currentHSV.v
//                                                alpha:1];
    }
    [self.delegate pickerColorChange:currentColor];
    [self.delegate pickerHSVChange:self.currentHSV];
}



- (BOOL) beginTrackingWithTouch: (UITouch*) touch
                      withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch:touch];
	return YES;
}



- (BOOL) continueTrackingWithTouch: (UITouch*) touch
                         withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch: touch];
	return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self trackIndicatorWithTouch: touch];
}

-(void)setHiddenIndicator:(BOOL)hidden{
    [indicator setHidden:hidden];
}


-(void)setCustomeImage:(UIImage *)image{
    if (image) {
        [_infColorSquareView setImage:image];
        self.isCustomeImage = YES;
        [_infColorSquareView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.leading.equalTo(self.mas_leading);
            make.trailing.equalTo(self.mas_trailing);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }else{
        [_infColorSquareView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.leading.equalTo(self.mas_leading);
            make.trailing.equalTo(self.mas_trailing);
            make.bottom.equalTo(self.mas_bottom);
        }];
        self.isCustomeImage = NO;
        [_infColorSquareView setImage:nil];
        [_infColorSquareView setHue:0.6];
    }
}

-(void)setSenceImage:(UIImage *)image{
    self.isCustomeImage = YES;
    [_infColorSquareView setImage:image];
    [_infColorSquareView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

-(void)setNewSenceImage:(UIImage *)image{
    self.isCustomeImage = YES;
    [_infColorSquareView setImage:image];
    [_infColorSquareView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(10);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@(260));
        make.width.equalTo(_infColorSquareView.mas_height);
    }];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}
@end


