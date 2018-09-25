//
//  InfColorSquarePicker.m
//  InfColorPicker
//
//  Created by Troy Gaul on 8/9/10.
//


#import "InfColorBarPicker.h"

#import "InfColorIndicatorView.h"
#import "InfHSBSupport.h"
#import "UIImage+ColorAtPixel.h"
#import "MyTool.h"


#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif



#define kContentInsetX 10
#define kContentInsetY 10

#define kIndicatorSize 30



@implementation InfColorBarView



//static CGImageRef createContentImage(int w,int h)
//{
//    float hsv[] = { 0.0f, 1.0f, 1.0f };
//    return createHSVBarContentImage(InfComponentIndexHue, hsv,w,h);
//}
//
//
//
//- (void) drawRect: (CGRect) rect
//{
//    CGImageRef image = createContentImage(rect.size.width,rect.size.height);
//    if (image) {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        
//        CGContextDrawImage(context, [self bounds], image);
//        
//        CGImageRelease(image);
//    }
//}
- (void) updateContent
{
//    float hsv[] = { 1.0f, 1.0f, 1.0f };
//    CGImageRef image = createHSVBarContentImage(InfComponentIndexHue, hsv,self.frame.size.width,self.frame.size.height);
//    self.image = [UIImage imageWithCGImage: image];
    [self setImage:[UIImage imageNamed:@"top"]];
}

#pragma mark	Properties


- (void) setHue: (float) value
{
	if (value != _hue || self.image == nil) {
		_hue = value;
		
		[self updateContent];
	}
}



@end



@implementation InfColorBarPicker {
	InfColorIndicatorView *indicator;
    InfColorBarView *_infColorBarView;
}

#pragma mark	Appearance

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _infColorBarView = [[InfColorBarView alloc]initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.height)];
        [_infColorBarView setHue:0.6];
        
        [self addSubview:_infColorBarView];
        if (indicator == nil) {
            CGRect indicatorRect = { CGPointZero, { kIndicatorSize, kIndicatorSize } };
            indicator = [[InfColorIndicatorView alloc] initWithFrame: indicatorRect];
            [self addSubview: indicator];
        }
        [indicator setHidden:YES];
    }
    return self;
}

- (void) setIndicatorColor
{
    
	if (indicator == nil)
    {
		return;
    }
//	indicator.color = [UIColor colorWithHue: self.value.x
//	                             saturation:1-self.value.y
//	                             brightness:1.0f
//	                                  alpha:1.0f];
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
	
	CGPoint touchValue;
	
	touchValue.x = ([touch locationInView: self].x - kContentInsetX)
				 / (bounds.size.width - 2 * kContentInsetX);
	
	touchValue.y = ([touch locationInView: self].y - kContentInsetY)
				 / (bounds.size.height - 2 * kContentInsetY);
	
	touchValue.x = pin(0.0f, touchValue.x, 1.0f);
	touchValue.y = 1.0f - pin(0.0f, touchValue.y, 1.0f);
   
	self.value = touchValue;
    [self.delegate barColorTemperature:touchValue.x];
    
    CGPoint point = [touch locationInView: self];
    CGRect rect = [_infColorBarView frame];
    UIImage *image = _infColorBarView.image ;
    image = [MyTool scale:image toSize:CGSizeMake(rect.size.width,rect.size.height)];
    indicator.color = [image colorAtPixel:point];
    [self.delegate barColorChange:indicator.color];
    CGFloat R, G, B;
    NSArray *rgbArray = [image RGBAtPixel:point];
    R = [[rgbArray objectAtIndex:0] floatValue];
    G = [[rgbArray objectAtIndex:1] floatValue];
    B = [[rgbArray objectAtIndex:2] floatValue];
    
    self.currentHSV = RGB_to_HSV(RGBTypeMake(R, G, B));
    [self.delegate barHSVChange:self.currentHSV];
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
    [self setNeedsLayout];
}

@end


