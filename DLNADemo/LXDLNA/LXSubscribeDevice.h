//
//  LXSubscribeDevice.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/21.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LXUPnPDevice;

@protocol LXSubscribeDeviceDelegate <NSObject>

@required
- (void)lx_subcirbeTransportStateCallback:(NSString *)transportState;
- (void)lx_subcirbeRelativeTimePositionCallback:(NSString *)relativeTimePosition;

@optional
- (void)lx_subcirbeSuccessOrFail:(BOOL)succesOrFail;
- (void)lx_contractSubscirbeSuccessOrFail:(BOOL)succesOrFail;
- (void)lx_removeSubscirbeSuccessOrFail:(BOOL)succesOrFail;

@end

/// 基于DLNA实现iOS，Android投屏：订阅事件通知
/// https://eliyar.biz/DLNA_with_iOS_Android_Part_3_Subscribe_Event/
@interface LXSubscribeDevice : NSObject

@property (nonatomic, strong) LXUPnPDevice *device;
@property (nonatomic, weak) id<LXSubscribeDeviceDelegate> delegate;
@property (nonatomic, assign) BOOL isRelativeTimePositionEnabled;

- (instancetype)initWithDevice:(LXUPnPDevice *)device;

/// 订阅
/// @param time  订阅过期时间，尽量保持在合理的时间范围，例如略大于投屏资源时长
/// @param serviceType  目前支持订阅Type：LXUPnPDevice_ServiceType_AVTransport和LXUPnPDevice_ServiceType_RenderingControl
- (void)sendSubcirbeWithTime:(int)time serviceType:(NSString *)serviceType;

/// 续订
/// @param time  续订时间
/// @param serviceType  目前支持订阅Type：LXUPnPDevice_ServiceType_AVTransport和LXUPnPDevice_ServiceType_RenderingControl
- (void)contractSubscirbeWithTime:(int)time serviceType:(NSString *)serviceType;

/// 退订
/// @discussion  尽量在投屏结束后手动退订
/// @param serviceType  目前支持订阅Type：LXUPnPDevice_ServiceType_AVTransport和LXUPnPDevice_ServiceType_RenderingControl
- (void)removeSubscirbeWithServiceType:(NSString *)serviceType;

@end

NS_ASSUME_NONNULL_END
