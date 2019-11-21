//
//  ControlDeviceController.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "ControlDeviceController.h"
#import "LXControlDevice.h"
#import "LXSubscribeDevice.h"
#import "LXUPnPStatusInfo.h"

@interface ControlDeviceController () <LXControlDeviceDelegate, LXSubscribeDeviceDelegate> {
    LXControlDevice *_control;
    float _currentTime;
    LXSubscribeDevice *_subscribe;
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
    
    LXSubscribeDevice *subscribe = [[LXSubscribeDevice alloc] initWithDevice:self.device];
    subscribe.delegate = self;
    [subscribe sendSubcirbeWithTime:3600 serviceType:LXUPnPDevice_ServiceType_AVTransport];
    _subscribe = subscribe;
}

#pragma mark - LXControlDeviceDelegate
- (void)lx_setAVTransportURLReponse {
    [_control play];
}

#pragma mark - LXSubscribeDeviceDelegate
- (void)lx_subcirbeTransportStateCallback:(NSString *)transportState {
    NSLog(@"订阅视频状态:---- %@", transportState);
}

- (void)lx_subcirbeRelativeTimePositionCallback:(NSString *)relativeTimePosition {
    NSLog(@"订阅进度状态:--- %@", relativeTimePosition);
}

- (void)lx_contractSubscirbeSuccessOrFail:(BOOL)succesOrFail {
    if (succesOrFail) {
        NSLog(@"续订成功！！！！");
    } else {
        NSLog(@"续订失败~~~~~");
    }
}

- (void)lx_removeSubscirbeSuccessOrFail:(BOOL)succesOrFail {
    if (succesOrFail) {
        NSLog(@"退订成功！！！！");
    } else {
        NSLog(@"退订失败~~~~~");
    }
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
    [_control setVolumeIncre:-5];
    //    [_control setVolume:2];
}

- (IBAction)upVolume:(id)sender {
    [_control setVolumeIncre:5];
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
    [_subscribe removeSubscirbeWithServiceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (IBAction)next:(id)sender {
    [_subscribe contractSubscirbeWithTime:30 serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (IBAction)switch:(id)sender {
}

@end
