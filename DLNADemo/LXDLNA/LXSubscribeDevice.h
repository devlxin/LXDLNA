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

- (void)sendSubcirbeWithTime:(int)time serviceType:(NSString *)serviceType;
- (void)contractSubscirbeWithTime:(int)time serviceType:(NSString *)serviceType;
- (void)removeSubscirbeWithServiceType:(NSString *)serviceType;

@end

NS_ASSUME_NONNULL_END
