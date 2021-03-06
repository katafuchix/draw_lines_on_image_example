//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

CGFloat SVProgressHUDRingRadius = 14;
CGFloat SVProgressHUDRingThickness = 6;

//custom hud iamge setting
NSString *const CUSTOM_HUD_BACKGROUND = @"custom_hud_bg.png";
NSString *const CUSTOM_SPINNER_IMAGE  = @"spinner.png";

//animation hud image setting
NSString *const ANIMATION_SPINNER_IMAGE  = @"spinner%d.png";
const int ANIMATION_COUNT = 15;


@interface SVProgressHUD ()

@property (nonatomic, readwrite) SVProgressHUDMaskType maskType;
@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *hudView;

@property (nonatomic, strong, readonly) UILabel *stringLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinnerView;

//custom
//@property (nonatomic, strong, readonly) UIImageView *customHudView;
@property (nonatomic, strong, readonly) UIView *customHudView;
@property (nonatomic, strong, readonly) UIImageView *customSpinnerView;

//animation
@property (nonatomic, strong, readonly) UIImageView *animationSpinnerView;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)showProgress:(float)progress
              status:(NSString*)string
            maskType:(SVProgressHUDMaskType)hudMaskType
    networkIndicator:(BOOL)show;

- (void)showImage:(UIImage*)image
           status:(NSString*)status
         duration:(NSTimeInterval)duration;

- (void)dismiss;

- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;

@end


@implementation SVProgressHUD

@synthesize overlayWindow,
            hudView,
            maskType,
            fadeOutTimer,
            stringLabel,
            imageView,
            spinnerView,
            visibleKeyboardHeight,
            customHudView,
            customSpinnerView,
            animationSpinnerView;

+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    static SVProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[SVProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}


+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show {
	[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeAnimation];
//    [[SVProgressHUD sharedView] showProgress:-1 status:nil maskType:SVProgressHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showWithStatus:(NSString *)status {
    [[SVProgressHUD sharedView] showProgress:-1 status:status maskType:SVProgressHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [[SVProgressHUD sharedView] showProgress:-1 status:nil maskType:maskType networkIndicator:NO];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    [[SVProgressHUD sharedView] showProgress:-1 status:status maskType:maskType networkIndicator:NO];
}

+ (void)showProgress:(CGFloat)progress {
    [[SVProgressHUD sharedView] showProgress:progress status:nil maskType:SVProgressHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status {
    [[SVProgressHUD sharedView] showProgress:progress status:status maskType:SVProgressHUDMaskTypeNone networkIndicator:NO];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status maskType:(SVProgressHUDMaskType)maskType {
    [[SVProgressHUD sharedView] showProgress:progress status:status maskType:maskType networkIndicator:NO];
}

#pragma mark - Show then dismiss methods

+ (void)showSuccessWithStatus:(NSString *)string {
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string];
}

+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [SVProgressHUD show];
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string];
}

+ (void)showErrorWithStatus:(NSString *)string {
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string];
}

+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [SVProgressHUD show];
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string {
    [[SVProgressHUD sharedView] showImage:image status:string duration:1.0];
}


#pragma mark - Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}

+ (void)dismissWithSuccess:(NSString*)string {
	[SVProgressHUD showSuccessWithStatus:string];
}

+ (void)dismissWithSuccess:(NSString *)string afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string duration:seconds];
}

+ (void)dismissWithError:(NSString*)string {
	[SVProgressHUD showErrorWithStatus:string];
}

+ (void)dismissWithError:(NSString *)string afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string duration:seconds];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
            
        case SVProgressHUDMaskTypeBlack: {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
            
        case SVProgressHUDMaskTypeGradient: {
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
    }
}

- (void)updatePosition {
	
    CGFloat hudWidth;
    CGFloat hudHeight;
    if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        hudWidth = self.customHudView.frame.size.width;
        hudHeight = self.customHudView.frame.size.height;
    }
    else
    {
        hudWidth = 100;
        hudHeight = 100;
    }

    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    NSString *string = self.stringLabel.text;
    // False if it's text-only
    BOOL imageUsed = (self.imageView.image) || (self.imageView.hidden);
    
    if(string) {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        
        if (imageUsed)
            hudHeight = 80+stringHeight;
        else
            hudHeight = 20+stringHeight;
        

        
        CGFloat labelRectY = imageUsed ? 66 : 9;
        
        if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
        {
            if(stringWidth > hudWidth)
                hudWidth = hudWidth;
            
            if(hudHeight > 100) {
                labelRect = CGRectMake(12, labelRectY, hudWidth, stringHeight);
                hudWidth+=24;
            } else {
                labelRect = CGRectMake(0, labelRectY, hudWidth, stringHeight);
                hudWidth+=24;
            }
        }
        else
        {
            if(stringWidth > hudWidth)
                hudWidth = ceil(stringWidth/2)*2;
            
            if(hudHeight > 100) {
                labelRect = CGRectMake(12, labelRectY, hudWidth, stringHeight);
                hudWidth+=24;
            } else {
                hudWidth+=24;
                labelRect = CGRectMake(0, labelRectY, hudWidth, stringHeight);
            }

        }
        
    }
	
    if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        self.customHudView.bounds = CGRectMake(0, 0, self.customHudView.frame.size.width, self.customHudView.frame.size.height);
        
        if(string)
            self.imageView.center = CGPointMake(CGRectGetWidth(self.customHudView.bounds)/2, 36);
        else
            self.imageView.center = CGPointMake(CGRectGetWidth(self.customHudView.bounds)/2, CGRectGetHeight(self.customHudView.bounds)/2);
        
        self.stringLabel.hidden = NO;
        self.stringLabel.frame = labelRect;
        
        if(string) {
            if (self.maskType == SVProgressHUDMaskTypeCustom)
            {
                self.customSpinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.customHudView.bounds)/2)+0.5, 40.5);
            }
            else if (self.maskType == SVProgressHUDMaskTypeAnimation)
            {
                self.animationSpinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.customHudView.bounds)/2)+0.5, 40.5);
            }
            
            if(self.progress != -1)
                self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.customHudView.bounds)/2), (CGRectGetWidth(self.customHudView.bounds)/2) - 36);
        }
        else
        {
            if (self.maskType == SVProgressHUDMaskTypeCustom)
            {
                self.customSpinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.customHudView.bounds)/2)+0.5, ceil(self.customHudView.bounds.size.height/2)+0.5);
            }
            else if (self.maskType == SVProgressHUDMaskTypeAnimation)
            {
                self.animationSpinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.customHudView.bounds)/2)+0.5, ceil(self.customHudView.bounds.size.height/2)+0.5);
            }
            self.customSpinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.customHudView.bounds)/2)+0.5, ceil(self.customHudView.bounds.size.height/2)+0.5);
            
            if(self.progress != -1)
                self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.customHudView.bounds)/2), CGRectGetWidth(self.customHudView.bounds)/2-SVProgressHUDRingRadius);
        }
    }
    else
    {
        self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
        
        if(string)
            self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
        else
            self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
        
        self.stringLabel.hidden = NO;
        self.stringLabel.frame = labelRect;
        
        if(string) {
            self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
            
            if(self.progress != -1)
                self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), (CGRectGetWidth(self.hudView.bounds)/2-SVProgressHUDRingRadius)-8);
        }
        else {
            self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
            
            if(self.progress != -1)
                self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetWidth(self.hudView.bounds)/2-SVProgressHUDRingRadius);
        }

    }
    
}

- (void)setStatus:(NSString *)string {
    
	self.stringLabel.text = string;
    [self updatePosition];
    
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    
    if(fadeOutTimer)
        [fadeOutTimer invalidate], fadeOutTimer = nil;
    
    if(newTimer)
        fadeOutTimer = newTimer;
}


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification 
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}


- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI; 
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    } 
    
    if(notification) {
        [UIView animateWithDuration:animationDuration 
                              delay:0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    } 
    
    else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    
    if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        self.customHudView.transform = CGAffineTransformMakeRotation(angle);
        self.customHudView.center = newCenter;
    }
    else
    {
        self.hudView.transform = CGAffineTransformMakeRotation(angle);
        self.hudView.center = newCenter;
    }
}

#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show {
    
    if(!self.superview)
    {
        [self.overlayWindow addSubview:self];
    }
    
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.maskType = hudMaskType;
    self.progress = progress;
    
    self.stringLabel.text = string;
    [self updatePosition];
    
    if(progress >= 0)
    {
        self.imageView.image = nil;
        self.imageView.hidden = NO;
        [self stopSpinning];
        self.ringLayer.strokeEnd = progress;
    }
    else
    {
        [self cancelRingLayerAnimation];
        [self startSpinning];
    }
    
    if (self.maskType != SVProgressHUDMaskTypeNone)
    {
        self.overlayWindow.userInteractionEnabled = NO;
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    }
    else
    {
        self.customHudView.hidden = YES;
    }


    [self.overlayWindow setHidden:NO];
    [self positionHUD:nil];
    
    
    if(self.alpha != 1) {
        [self registerNotifications];
        
        if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
        {
            self.customHudView.hidden = NO;
            self.customHudView.transform = CGAffineTransformScale(self.customHudView.transform, 1.3, 1.3);
            
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.customHudView.transform = CGAffineTransformScale(self.customHudView.transform, 1/1.3, 1/1.3);
                                 self.alpha = 1;
                             }
                             completion:^(BOOL finished){
                                 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, string);
                             }];
        }
        else
        {
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
            
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                                 self.alpha = 1;
                             }
                             completion:^(BOOL finished){
                                 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, string);
                             }];

        }

    }
    [self setNeedsDisplay];
}


- (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration {
    
    [self cancelRingLayerAnimation];
    
    if(![SVProgressHUD isVisible])
        [SVProgressHUD show];
    
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.stringLabel.text = string;
    [self updatePosition];
    [self stopSpinning];
    
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}


- (void)dismiss
{
    if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.customHudView.transform = CGAffineTransformScale(self.customHudView.transform, 0.8, 0.8);
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [[NSNotificationCenter defaultCenter] removeObserver:self];
                                 [self cancelRingLayerAnimation];
                                 [customHudView removeFromSuperview];
                                 customHudView = nil;
                                 
                                 [overlayWindow removeFromSuperview];
                                 overlayWindow = nil;
                                 
                                 // fixes bug where keyboard wouldn't return as keyWindow upon dismissal of HUD
                                 [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id window, NSUInteger idx, BOOL *stop) {
                                     if([window isMemberOfClass:[UIWindow class]]) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                                 
                                 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                                 
                                 // uncomment to make sure UIWindow is gone from app.windows
                                 //NSLog(@"%@", [UIApplication sharedApplication].windows);
                                 //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                             }
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [[NSNotificationCenter defaultCenter] removeObserver:self];
                                 [self cancelRingLayerAnimation];
                                 [hudView removeFromSuperview];
                                 hudView = nil;
                                 
                                 [overlayWindow removeFromSuperview];
                                 overlayWindow = nil;
                                 
                                 // fixes bug where keyboard wouldn't return as keyWindow upon dismissal of HUD
                                 [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id window, NSUInteger idx, BOOL *stop) {
                                     if([window isMemberOfClass:[UIWindow class]]) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                                 
                                 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                                 
                                 // uncomment to make sure UIWindow is gone from app.windows
                                 //NSLog(@"%@", [UIApplication sharedApplication].windows);
                                 //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                             }
                         }];
    }
}


#pragma mark -
#pragma mark Ring progress animation

- (CAShapeLayer *)ringLayer {
    
    if(!_ringLayer) {
        
        if (maskType == SVProgressHUDMaskTypeCustom || maskType == SVProgressHUDMaskTypeAnimation)
        {
            CGPoint center = CGPointMake(CGRectGetWidth(customHudView.frame)/2, CGRectGetHeight(customHudView.frame)/2);
            _ringLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor whiteColor]];
            [self.customHudView.layer addSublayer:_ringLayer];
        }
        else
        {
            CGPoint center = CGPointMake(CGRectGetWidth(hudView.frame)/2, CGRectGetHeight(hudView.frame)/2);
            _ringLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor whiteColor]];
            [self.hudView.layer addSublayer:_ringLayer];
        }
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer {
    
    if(!_backgroundRingLayer) {
        
        if (maskType == SVProgressHUDMaskTypeCustom || maskType == SVProgressHUDMaskTypeAnimation)
        {
            CGPoint center = CGPointMake(CGRectGetWidth(customHudView.frame)/2, CGRectGetHeight(customHudView.frame)/2);
            _backgroundRingLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor darkGrayColor]];
            _backgroundRingLayer.strokeEnd = 1;
            [self.customHudView.layer addSublayer:_backgroundRingLayer];
        }
        else
        {
            CGPoint center = CGPointMake(CGRectGetWidth(hudView.frame)/2, CGRectGetHeight(hudView.frame)/2);
            _backgroundRingLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor darkGrayColor]];
            _backgroundRingLayer.strokeEnd = 1;
            [self.hudView.layer addSublayer:_backgroundRingLayer];
        }
    }
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (maskType == SVProgressHUDMaskTypeCustom)
    {
        [customHudView.layer removeAllAnimations];
    }
    else if (maskType == SVProgressHUDMaskTypeAnimation)
    {
        [animationSpinnerView stopAnimating];
    }
    else
    {
        [hudView.layer removeAllAnimations];
    }
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(double)radius angleInDegrees:(double)angleInDegrees {
    float x = (float)(radius * cos(angleInDegrees * M_PI / 180)) + radius;
    float y = (float)(radius * sin(angleInDegrees * M_PI / 180)) + radius;
    return CGPointMake(x, y);
}


- (UIBezierPath *)createCirclePathWithCenter:(CGPoint)center radius:(CGFloat)radius sampleCount:(NSInteger)sampleCount {
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    CGPoint startPoint = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:-90];
    
    [smoothedPath moveToPoint:startPoint];
    
    CGFloat delta = 360.0f/sampleCount;
    CGFloat angleInDegrees = -90;
    for (NSInteger i=1; i<sampleCount; i++) {
        angleInDegrees += delta;
        CGPoint point = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:angleInDegrees];
        [smoothedPath addLineToPoint:point];
    }
    
    [smoothedPath addLineToPoint:startPoint];
    
    return smoothedPath;
}


- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    
    UIBezierPath *smoothedPath = [self createCirclePathWithCenter:center radius:radius sampleCount:72];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([SVProgressHUD sharedView].alpha == 1);
}


#pragma mark - Getters

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
        overlayWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return overlayWindow;
}

- (UIView *)hudView {
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
		hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    return hudView;
}

//- (UIImageView *)customHudView
//{
//    if(!customHudView)
//	{
//        UIImage *customHudImage = [UIImage imageNamed:CUSTOM_HUD_BACKGROUND];
//        customHudView = [[UIImageView alloc] initWithImage:customHudImage];
//        [self addSubview:customHudView];
//    }
//    return customHudView;
//}
- (UIView *)customHudView
{
    if(!customHudView)
	{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, overlayWindow.bounds.size.width, overlayWindow.bounds.size.height - 32)];
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.9;
        customHudView = view;
        [self addSubview:customHudView];
    }
    return customHudView;
}


- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
			stringLabel.textAlignment = UITextAlignmentCenter;
		#else
			stringLabel.textAlignment = NSTextAlignmentCenter;
		#endif
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
    }
    
    if(!stringLabel.superview)
    {
        if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
        {
            [self.customHudView addSubview:stringLabel];
        }
        else
        {
            [self.hudView addSubview:stringLabel];
        }
    }
    return stringLabel;
}

- (UIImageView *)imageView {
    if (imageView == nil)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    if(!imageView.superview)
    {
        if (self.maskType == SVProgressHUDMaskTypeCustom || self.maskType == SVProgressHUDMaskTypeAnimation)
        {
            [self.customHudView addSubview:imageView];
        }
        else
        {
            [self.hudView addSubview:imageView];
        }
    }
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView
{
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
    }
    
    if(!spinnerView.superview)
    {
        [self.hudView addSubview:spinnerView];;
    }
    return spinnerView;
}

- (void)startSpinning
{
    self.spinnerView.hidden = YES;
    self.customSpinnerView.hidden = YES;
    self.animationSpinnerView.hidden = YES;
    
    if (self.maskType == SVProgressHUDMaskTypeCustom)
    {
        self.spinnerView.hidden = YES;
        self.customSpinnerView.hidden = NO;
        self.animationSpinnerView.hidden = YES;
        
        CGFloat rotations = 1.0f;
        CGFloat duration = 1.0f;
        float repeat = 1000.f;
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
        rotationAnimation.duration = duration;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = repeat;
        
        [self.customSpinnerView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    else if (self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        self.spinnerView.hidden = YES;
        self.customSpinnerView.hidden = YES;
        self.animationSpinnerView.hidden = NO;
        self.animationSpinnerView.center = self.customHudView.center;
        [self.animationSpinnerView startAnimating];
    }
    else
    {
        [self.spinnerView startAnimating];
    }
}

- (void)stopSpinning
{
    self.spinnerView.hidden = YES;
    self.customSpinnerView.hidden = YES;
    self.animationSpinnerView.hidden = YES;
    
    if (self.maskType == SVProgressHUDMaskTypeCustom)
    {
        [self.customSpinnerView.layer removeAllAnimations];
        self.customSpinnerView.hidden = YES;
    }
    else if (self.maskType == SVProgressHUDMaskTypeAnimation)
    {
        [self.animationSpinnerView stopAnimating];
        self.animationSpinnerView.hidden = YES;
    }
    else
    {
        [self.spinnerView stopAnimating];
    }
}


- (UIImageView *)customSpinnerView
{
    UIImage *customSpinnerImage = [UIImage imageNamed:CUSTOM_SPINNER_IMAGE];
    if (customSpinnerView == nil)
    {
        customSpinnerView = [[UIImageView alloc]initWithImage:customSpinnerImage];
		customSpinnerView.bounds = CGRectMake(0, 0, 36, 36);
    }
    
    if(!customSpinnerView.superview)
    {
        [self.customHudView addSubview:customSpinnerView];
    }
    return customSpinnerView;
}

- (UIImageView *)animationSpinnerView
{
    int animationCount = ANIMATION_COUNT;
    NSMutableArray *spinners = [NSMutableArray arrayWithCapacity:0];
    NSString *animationItem;
    UIImage *animationImage;
    
    for (int i = 0; i < animationCount; i++)
    {
        animationItem =  [NSString stringWithFormat:ANIMATION_SPINNER_IMAGE,i];
        animationImage = [UIImage imageNamed:animationItem];
        [spinners addObject:animationImage];
    }
    
    if (animationSpinnerView == nil) {
        animationSpinnerView = [[UIImageView alloc]initWithImage:spinners[0]];
        animationSpinnerView.animationImages = spinners;
        animationSpinnerView.animationDuration = 3.0f;
        animationSpinnerView.animationRepeatCount = 0;
        animationSpinnerView.bounds = CGRectMake(0, 0, 260, 34);
    }
    if(!animationSpinnerView.superview)
    {
        [customHudView addSubview:animationSpinnerView];
    }
    return animationSpinnerView;
}

- (CGFloat)visibleKeyboardHeight {
        
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
            return possibleKeyboard.bounds.size.height;
    }
    
    return 0;
}

@end
