//
//  ControlDeviceController.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "ControlDeviceController.h"
#import "LXControlDevice.h"

@interface ControlDeviceController () <LXControlDeviceDelegate> {
    LXControlDevice *_control;
    float _currentTime;
}

@end

@implementation ControlDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"控制设备"];

    LXControlDevice *control = [[LXControlDevice alloc] initWithDevice:self.device];
    control.delegate = self;
    [control setAVTransportURL:self.url];
    _control = control;
}

#pragma mark - LXControlDeviceDelegate
- (void)lx_setAVTransportURLReponse {
    [_control play];
}

- (void)lx_getTransportInfoResponse:(LXUPnPTransportInfo *)transportInfo {
    if ([transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Transitioning]) {
        NSLog(@"连接中");
    } else if ([transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Playing]) {
        NSLog(@"正在播放");
    } else if ([transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Stopped]) {
        NSLog(@"播放已停止");
    } else if ([transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Paused]) {
        NSLog(@"播放已暂停");
    } else {
        NSLog(@"其他状态：%@", transportInfo.currentTransportState);
    }
}

- (void)lx_getPositionInfoResponse:(LXUPnPAVPositionInfo *)info {
    _currentTime = info.relTime;
}

- (void)lx_getVolumeResponse:(NSString *)volume {
    NSLog(@"音量：%@", volume);
}

- (void)lx_undefinedResponse:(NSString *)responseXML {
    NSLog(@"%@", responseXML);
}

- (void)lx_stopResponse {
    NSLog(@"播放停止");
}

#pragma mark - action
- (IBAction)play:(id)sender {
    [_control play];
}

- (IBAction)pause:(id)sender {
    [_control pause];
}

- (IBAction)stop:(id)sender {
    [_control stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)downVolume:(id)sender {
    [_control setVolumeIncre:-1];
//    [_control setVolume:2];
}

- (IBAction)upVolume:(id)sender {
    [_control setVolumeIncre:1];
//    [_control setVolume:100];
}

- (IBAction)seekGo:(id)sender {
//    [_control seekToTime:_currentTime + 10];
    [_control seekToTimeIncre:10];
}

- (IBAction)seekBack:(id)sender {
//    [_control seekToTime:_currentTime - 10];
    [_control seekToTimeIncre:-10];
}

- (IBAction)previous:(id)sender {
}

- (IBAction)next:(id)sender {
    [_control getVolume];
}

- (IBAction)switch:(id)sender {
}

@end
