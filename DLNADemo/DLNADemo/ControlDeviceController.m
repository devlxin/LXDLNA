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
    if ([transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Playing] || [transportInfo.currentTransportState isEqualToString:LXUPnPTransportInfo_Status_Transitioning]) {
        [_control play];
    }
}

- (void)lx_getPositionInfoResponse:(LXUPnPAVPositionInfo *)info {
    _currentTime = info.trackDuration;
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
}

- (IBAction)downVolume:(id)sender {
    [_control setVolumeIncre:-1];
}

- (IBAction)upVolume:(id)sender {
    [_control setVolumeIncre:1];
}

- (IBAction)seekGo:(id)sender {
    [_control seekToTime:_currentTime + 20];
}

- (IBAction)seekBack:(id)sender {
    [_control seekToTime:_currentTime - 20];
}

- (IBAction)previous:(id)sender {
}

- (IBAction)next:(id)sender {
}

- (IBAction)switch:(id)sender {
}

@end
