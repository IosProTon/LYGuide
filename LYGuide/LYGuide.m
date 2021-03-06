//
//  LYGuide.m
//  LYIntroductionDemo
//
//  Created by 李尧 on 2016/10/31.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "LYGuide.h"
#import "LYGuideConfig.h"
#import <objc/runtime.h>
#import "LYIntroductionView.h"
#import "LYGuideManager.h"

static char (* const kGuideHandler) = "kGuideHandler";

@interface LYGuide()<LYIntroductionDelegate, UIAppearanceContainer>{
    NSTimeInterval _lastStamp;
}

@property (strong, nonatomic) LYIntroductionView *introductionView;
@property (nonatomic, assign) CGRect hintRect;
@property (nonatomic, assign) CGRect originRect;

@end
@implementation LYGuide
@synthesize borderScale = _borderScale;
@synthesize cornerRadius = _cornerRadius;
@synthesize borderColor = _borderColor;
@synthesize hintColor = _hintColor;
@synthesize baseBackgroundColor = _baseBackgroundColor;
@synthesize font = _font;
@synthesize textColor = _textColor;


+ (instancetype)guideWithText:(NSString *)text
                       target:(CGRect)rect
                      handler:(LYGuideHandler)block {
    if (CGRectEqualToRect(rect, CGRectZero) || CGRectEqualToRect(rect, CGRectNull)) {
        @throw [NSException exceptionWithName:@"LYGuideException" reason:@"Guide rect can not be CGRectZero or CGRectNull" userInfo:nil];
    }
    LYGuide *instance = [[self alloc] initPrivate];
    instance.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    instance.originRect = rect;
    CGRect newScaleRect = CGRectInset(rect, -(instance.borderScale.width-1.0f)*rect.size.width, -(instance.borderScale.height-1.0f)*rect.size.height);
    instance.hintRect = newScaleRect;   //hintView Rect
    instance.introductionView.hintLabel.font = instance.font;
    instance.text = text;
    [instance.introductionView hintViewUpdateWithFrame:newScaleRect borderColor:instance.borderColor hintColor:instance.hintColor baseBackgroundColor:instance.baseBackgroundColor cornerRadius:instance.cornerRadius text:text textColor:instance.textColor];
    [instance addSubview:instance.introductionView];
    
    objc_setAssociatedObject(instance, kGuideHandler, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    instance.introductionView.delegate = instance;
    
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _borderScale = [LYGuideConfig shared].borderScale;
        _cornerRadius = [LYGuideConfig shared].cornerRadius;
        _intercepted = [LYGuideConfig shared].intercepted;
        _animated = [LYGuideConfig shared].animated;
        _displayed = NO;
        _repeatCount = [LYGuideConfig shared].repeatCount;
        _currentRepeatCount = 0;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// priority won't work there.
+ (void)registerGuides:(NSArray <LYGuide *>*)guides
                  target:(Class)cls
        completion:(LYGuidesCompletionBlock)block {
    [[LYGuideManager shared] registerGuides:guides target:cls completion:block];
}

+ (void)showNextFrom:(Class)cls {
    [[LYGuideManager shared] showNextFrom:cls];
}

+ (LYGuideConfig *)defaultConfig {
    return [LYGuideConfig shared];
}

- (void)show {
    if (_repeatCount <= 0 || _currentRepeatCount < _repeatCount) {
        if(!self.isAnimated){
            [[[[[[UIApplication sharedApplication] windows] firstObject] subviews] firstObject] addSubview:self];
        }else{
            self.alpha = 0;
            [[[[[[UIApplication sharedApplication] windows] firstObject] subviews] firstObject] addSubview:self];
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished){
                self.alpha = 1;
            }];
        }
        _currentRepeatCount ++;
        _displayed = YES;
    }
}
- (void)showWithPriority:(NSInteger)priority {
    
}

- (void)dismiss {
    if(!self.isAnimated){
        [self removeFromSuperview];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - Hit-Test
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.intercepted){
        // HitTest will run 2 times, so we compare the timeStamp with the lastStamp.
        if(CGRectContainsPoint(self.hintRect, point) && event.timestamp!=_lastStamp){
            void (^guideHandler) (LYGuide *, BOOL) = objc_getAssociatedObject(self, kGuideHandler);
            if (guideHandler) {
                guideHandler (self, YES);
            }
            return nil;
        }
        _lastStamp = event.timestamp;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - private
- (void)reload {
    [self.introductionView hintViewUpdateWithFrame:self.hintRect borderColor:self.borderColor hintColor:self.hintColor baseBackgroundColor:self.baseBackgroundColor cornerRadius:self.cornerRadius text:self.text textColor:self.textColor];
}

#pragma mark - LYIntroductionDelegate
- (void) tapEventOnHintView:(BOOL)onHintView {
    if(self.intercepted){
        void (^guideHandler) (LYGuide *, BOOL) = objc_getAssociatedObject(self, kGuideHandler);
        if (guideHandler) {
            guideHandler (self, onHintView);
        }
    }else{
        //If it is not intercepted, call the guideHandler only when the tap-gesture is not on hintView;
        if(!onHintView){
            void (^guideHandler) (LYGuide *, BOOL) = objc_getAssociatedObject(self, kGuideHandler);
            if (guideHandler) {
                guideHandler (self, onHintView);
            }
        }
    }
}

#pragma mark - getter && setter
- (LYIntroductionView *)introductionView {
    if(_introductionView == nil){
        _introductionView = [[LYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _introductionView;
}

- (CGSize)borderScale {
    if(CGSizeEqualToSize(_borderScale, CGSizeZero)){
        _borderScale = [LYGuideConfig shared].borderScale;
    }
    return _borderScale;
}

- (CGFloat)cornerRadius {
    if(_cornerRadius < 0){
        _cornerRadius = [LYGuideConfig shared].cornerRadius;
    }
    return _cornerRadius;
}

- (UIColor *)borderColor {
    if(_borderColor == nil){
        _borderColor = [LYGuideConfig shared].borderColor;
    }
    return _borderColor;
}

- (UIColor *)hintColor {
    if(_hintColor == nil){
        _hintColor = [LYGuideConfig shared].hintColor;
    }
    return _hintColor;
}

- (UIColor *)baseBackgroundColor {
    if(_baseBackgroundColor == nil){
        _baseBackgroundColor = [LYGuideConfig shared].baseBackgroundColor;
    }
    return _baseBackgroundColor;
}

- (UIFont *)font {
    if(_font == nil){
        _font = [LYGuideConfig shared].font;
    }
    return _font;
}

- (UIColor *)textColor {
    if(_textColor == nil){
        _textColor = [LYGuideConfig shared].textColor;
    }
    return _textColor;
}

- (NSString *)text {
    if (_text == nil) {
        _text = @"";
    }
    return _text;
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (CGColorEqualToColor(borderColor.CGColor, _borderColor.CGColor)) {
        return;
    }
    _borderColor = borderColor;
    [self reload];
}

- (void)setHintColor:(UIColor *)hintColor {
    if (CGColorEqualToColor(hintColor.CGColor, _hintColor.CGColor)) {
        return;
    }
    _hintColor = hintColor;
    [self reload];
}

- (void)setTextColor:(UIColor *)textColor {
    if (CGColorEqualToColor(textColor.CGColor, _textColor.CGColor)) {
        return;
    }
    _textColor = textColor;
    [self reload];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius == _cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    [self reload];
}

- (void)setBorderScale:(CGSize)borderScale {
    if (CGSizeEqualToSize(borderScale, _borderScale)) {
        return;
    }
    _borderScale = borderScale;
    CGRect newScaleRect = CGRectInset(self.originRect, -(self.borderScale.width-1.0f)*self.originRect.size.width, -(self.borderScale.height-1.0f)*self.originRect.size.height);
    self.hintRect = newScaleRect;
    [self reload];
}

- (void)setBaseBackgroundColor:(UIColor *)baseBackgroundColor {
    if (CGColorEqualToColor(baseBackgroundColor.CGColor, _baseBackgroundColor.CGColor)) {
        return;
    }
    _baseBackgroundColor = baseBackgroundColor;
    [self reload];
}

@end


#pragma mark - UIView+LYGuide
@implementation UIView (LYGuide)

- (CGRect)lyg_absoluteFrame {
    return [self convertRect:self.bounds toView:self.window];
}
@end

#pragma mark - UITableView+LYGuide
@implementation UITableView (LYGuide)

- (UIView *)lyg_getCellFrom:(NSIndexPath *)indexPath {
    NSIndexPath *index =  [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
    return [self cellForRowAtIndexPath:index];
}
@end


