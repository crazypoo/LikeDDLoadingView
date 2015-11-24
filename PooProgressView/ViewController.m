//
//  ViewController.m
//  PooProgressView
//
//  Created by 邓杰豪 on 15/11/24.
//  Copyright © 2015年 邓杰豪. All rights reserved.
//

#import "ViewController.h"

#import "PooProgressView.h"

@interface ViewController ()
{
    PooProgressView *_progressView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _progressView = [[PooProgressView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 240) / 2.0f, (self.view.frame.size.height - 240) / 2.0f, 240, 240)];
    [_progressView setAnimationTime:10];
    _progressView.start = ^() {
        NSLog(@"开始");
    };
    _progressView.animing = ^ (NSTimeInterval currentTime) {
        NSLog(@"进行中");
    };
    __strong PooProgressView *views = _progressView;
    _progressView.stop = ^ () {
        NSLog(@"结束");
        views.hidden = YES;
    };
    [self.view addSubview:_progressView];

    [_progressView startAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
