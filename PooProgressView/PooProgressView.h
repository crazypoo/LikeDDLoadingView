//
//  CCProgressView.h
//  PooProgressView
//
//  Created by 邓杰豪 on 15/11/24.
//  Copyright © 2015年 邓杰豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 * 动画开始
 */
typedef void(^block_progress_start)();

/**
 * 动画正在进行
 * @param NSTimeInterval
 */
typedef void(^block_progress_animing)(NSTimeInterval);

/**
 * 动画结束
 */
typedef void(^block_progress_stop)();

@interface PooProgressView : UIView
{
    NSTimeInterval _animationTime;
}

@property (nonatomic, strong) UILabel *centerLabel;    // 中心Label

@property (nonatomic, copy) block_progress_start start;   // 动画开始回调
@property (nonatomic, copy) block_progress_animing animing; // 动画进行
@property (nonatomic, copy) block_progress_stop stop;    // 动画结束回调

- (void)setAnimationTime:(NSTimeInterval)animationTime;

- (void)startAnimation;

- (void)stopAnimation;

@end
