//
//  ViewController.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "ViewController.h"
#import "FindDeviceController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"DLNADemo"];
    
    [self sendTestRequest];
    
    UIBarButtonItem *airPlay = [[UIBarButtonItem alloc] initWithTitle:@"AirPlay" style:UIBarButtonItemStyleDone target:self action:@selector(airPlay)];
    [self.navigationItem setRightBarButtonItem:airPlay];
}

- (void)airPlay {
    MPVolumeView *volume = [[MPVolumeView alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    volume.showsVolumeSlider = NO;
    [volume sizeToFit];
    [self.view addSubview:volume];
}

- (IBAction)findDevice:(id)sender {
    FindDeviceController *findDevice = [[FindDeviceController alloc] init];
    [self.navigationController pushViewController:findDevice animated:YES];
}

/**
 DLNA功能只有在用户允许了网络权限后才能使用
 */
- (void)sendTestRequest {
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSMutableURLRequest *requst = [[NSMutableURLRequest alloc]initWithURL:url];
    requst.HTTPMethod = @"GET";
    requst.timeoutInterval = 5;
    [NSURLConnection sendAsynchronousRequest:requst queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError.description) {
            NSLog(@"网络正常");
        } else {
            NSLog(@"=========>网络异常");
        }
    }];
}

@end
