//
//  LXFindDevice.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LXUPnPDevice;

@protocol LXFindDeviceDelegate <NSObject>

@required
- (void)lx_UPnPDeviceChanged:(NSArray<LXUPnPDevice *> *)devices;

@optional
- (void)lx_UPnPDeviceFindFaild:(NSError *)error;

@end

/// 基于DLNA实现iOS，Android投屏：SSDP发现UPnP设备
/// https://eliyar.biz/DLNA_with_iOS_Android_Part_1_Find_Device_Using_SSDP/
@interface LXFindDevice : NSObject

@property (nonatomic, weak) id<LXFindDeviceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)startFindDevice;
- (void)stopFindDevice;

@end

NS_ASSUME_NONNULL_END
