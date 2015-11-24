//
//  CCProgressView.m
//  PooProgressView
//
//  Created by 邓杰豪 on 15/11/24.
//  Copyright © 2015年 邓杰豪. All rights reserved.
//

#import "PooProgressView.h"

#define kProgressThumbWh 30

// 计时器间隔时长
#define kAnimTimeInterval 0.1

/**
 * 圆圈layer上旋转的layer
 */
@interface PooProgressThumb : CALayer
{
    NSTimeInterval _animationTime;
}

@property (assign, nonatomic) double startAngle;
@property (nonatomic, strong) UILabel *timeLabel;      // 显示时间Label

@end

@implementation PooProgressThumb

- (instancetype)init
{
    if ((self = [super init])) {
        [self setupLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    _timeLabel.frame = self.bounds;

    [_timeLabel sizeToFit];
    _timeLabel.center = CGPointMake(CGRectGetMidX(self.bounds) - _timeLabel.frame.origin.x,
                                    CGRectGetMidY(self.bounds) - _timeLabel.frame.origin.y);
}

- (void)setupLayer
{
    // 绘制圆
    UIGraphicsBeginImageContext(CGSizeMake(kProgressThumbWh, kProgressThumbWh));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(1, 1, kProgressThumbWh - 2, kProgressThumbWh - 2));
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *circleView = [[UIImageView alloc] initWithImage:circle];
    circleView.frame = CGRectMake(0, 0, kProgressThumbWh, kProgressThumbWh);
    circleView.image = circle;
    [self addSublayer:circleView.layer];

    _timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _timeLabel.textColor = [UIColor redColor];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"00:00";
    [self addSublayer:_timeLabel.layer];

    _startAngle = - M_PI / 2;
}

- (void)setAnimationTime:(NSTimeInterval)animationTime
{
    _animationTime = animationTime;
}

- (double)calculatePercent:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    double progress = 0.0f;
    if ((toTime > 0) && (fromTime > 0)) {
        progress = fromTime / toTime;
        if ((progress * 100) > 100) {
            progress = 1.0f;
        }
    }
    return progress;
}

- (void)startAnimation
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.duration = kAnimTimeInterval;
    pathAnimation.repeatCount = 0;
    pathAnimation.autoreverses = YES;

    CGMutablePathRef arcPath = CGPathCreateMutable();
    CGPathAddPath(arcPath, NULL, [self bezierPathFromParentLayerArcCenter]);
    pathAnimation.path = arcPath;
    CGPathRelease(arcPath);
    [self addAnimation:pathAnimation forKey:@"position"];
}

/**
 * 根据父Layer获取到一个移动路径
 * @return
 */
- (CGPathRef)bezierPathFromParentLayerArcCenter
{
    CGFloat centerX = CGRectGetWidth(self.superlayer.frame) / 2.0;
    CGFloat centerY = CGRectGetHeight(self.superlayer.frame) / 2.0;
    double tmpStartAngle = _startAngle;
    _startAngle = _startAngle + (2 * M_PI) * kAnimTimeInterval / _animationTime;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                          radius:centerX
                                      startAngle:tmpStartAngle
                                        endAngle:_startAngle
                                       clockwise:YES].CGPath;
}

- (void)stopAnimation
{
    [self removeAllAnimations];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

/**
 * 圆圈layer
 */
@interface PooProgress : CAShapeLayer
{
    NSTimeInterval _animationTime;
}

@property (assign, nonatomic) double initialProgress;
@property (nonatomic) NSTimeInterval elapsedTime;                   //已使用时间
@property (assign, nonatomic) double percent;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) CAShapeLayer *progress;
@property (nonatomic, strong) PooProgressThumb *thumb;

@end

@implementation PooProgress

- (instancetype) init
{
    if ((self = [super init])) {
        [self setupLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    self.path = [self bezierPathWithArcCenter];
    self.progress.path = self.path;

    self.thumb.frame = CGRectMake((320 - kProgressThumbWh) / 2.0f, 180, kProgressThumbWh, kProgressThumbWh);
    [super layoutSublayers];
}

- (void)setupLayer
{
    // 绘制圆
    self.path = [self bezierPathWithArcCenter];
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:0.4f].CGColor;
    self.lineWidth = 2;

    // 添加可以变动的滚动条
    self.progress = [CAShapeLayer layer];
    self.progress.path = self.path;
    self.progress.fillColor = [UIColor clearColor].CGColor;
    self.progress.strokeColor = [UIColor whiteColor].CGColor;
    self.progress.lineWidth = 4;
    self.progress.lineCap = kCALineCapSquare;
    self.progress.lineJoin = kCALineCapSquare;
    [self addSublayer:self.progress];

    // 添加可以旋转的ThumbLayer
    self.thumb = [[PooProgressThumb alloc] init];
    [self addSublayer:self.thumb];
}

/**
 * 得到bezier曲线路劲
 * @return
 */
- (CGPathRef)bezierPathWithArcCenter
{
    CGFloat centerX = CGRectGetWidth(self.frame) / 2.0;
    CGFloat centerY = CGRectGetHeight(self.frame) / 2.0;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                          radius:centerX
                                      startAngle:(- M_PI / 2)
                                        endAngle:(3 * M_PI / 2)
                                       clockwise:YES].CGPath;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    self.progress.strokeColor = circleColor.CGColor;
}

- (void)setAnimtionTime:(NSTimeInterval)animtionTime
{
    _animationTime = animtionTime;
    [self.thumb setAnimationTime:animtionTime];
}

- (void)setElapsedTime:(NSTimeInterval)elapsedTime
{
    _initialProgress = [self calculatePercent:_elapsedTime toTime:_animationTime];
    _elapsedTime = elapsedTime;

    self.progress.strokeEnd = self.percent;
    [self startAnimation];
}

- (double)percent
{
    _percent = [self calculatePercent:_elapsedTime toTime:_animationTime];
    return _percent;
}

- (double)calculatePercent:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    double progress = 0.0f;
    if ((toTime > 0) && (fromTime > 0)) {
        progress = fromTime / toTime;
        if ((progress * 100) > 100) {
            progress = 1.0f;
        }
    }
    return progress;
}

- (void)startAnimation
{
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = kAnimTimeInterval;
    pathAnimation.fromValue = @(self.initialProgress);
    pathAnimation.toValue = @(self.percent);
    pathAnimation.removedOnCompletion = YES;
    [self.progress addAnimation:pathAnimation forKey:nil];

    [self.thumb startAnimation];
    self.thumb.timeLabel.text = [self stringFromTimeInterval:_elapsedTime shorTime:YES];
}

- (void)stopAnimation
{
    _elapsedTime = 0;
    self.progress.strokeEnd = 0.0;
    [self removeAllAnimations];
    [self.thumb stopAnimation];
}

/**
 * 时间格式转换
 * @param interval NSTimeInterval
 * @param shortTime BOOL
 * @return
 */
- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval shorTime:(BOOL)shortTime
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (shortTime) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)hours, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
}

@end

@interface PooProgressView ()

@property (nonatomic, strong) PooProgress *progressLayer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PooProgressView

- (instancetype)init
{
    if ((self = [super init])) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.progressLayer.frame = self.bounds;

    [self.centerLabel sizeToFit];
    self.centerLabel.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y- self.frame.origin.y);
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = false;

    self.progressLayer = [[PooProgress alloc] init];
    self.progressLayer.frame = self.bounds;
    [self.layer addSublayer:self.progressLayer];

    _centerLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _centerLabel.font = [UIFont systemFontOfSize:18];
    _centerLabel.textAlignment = NSTextAlignmentCenter;
    _centerLabel.textColor = [UIColor whiteColor];
    _centerLabel.text = @"已推送至 3 家";
    [self.layer addSublayer:_centerLabel.layer];
}

- (void)setAnimationTime:(NSTimeInterval)animationTime
{
    _animationTime = animationTime;
    [self.progressLayer setAnimtionTime:animationTime];
}

- (void)startAnimation
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:kAnimTimeInterval target:self selector:@selector(doTimerSchedule) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    self.progressLayer.elapsedTime = 0;
    if (_start) _start();
}

- (void)doTimerSchedule
{
    self.progressLayer.elapsedTime = self.progressLayer.elapsedTime + kAnimTimeInterval;;
    if (_animing) _animing(self.progressLayer.elapsedTime);
    
    if (self.progressLayer.elapsedTime >= _animationTime) {
        [self stopAnimation];
    }
}

- (void)stopAnimation
{
    if (_stop) _stop();
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_progressLayer stopAnimation];
}

@end
