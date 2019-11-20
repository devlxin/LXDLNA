//
//  LXUPnPDevice.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LXDLNA_kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO)

@class LXUPnPDeviceService;

static NSString *LXUPnPDevice_ServiceType_AVTransport = @"urn:schemas-upnp-org:service:AVTransport:1";
static NSString *LXUPnPDevice_ServiceType_RenderingControl = @"urn:schemas-upnp-org:service:RenderingControl:1";

static NSString *LXUPnPDevice_ServiceId_AVTransport = @"urn:upnp-org:serviceId:AVTransport";
static NSString *LXUPnPDevice_ServiceId_RenderingControl = @"urn:upnp-org:serviceId:RenderingControl";

/// 投屏设备信息
@interface LXUPnPDevice : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSURL *location;

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;

@property (nonatomic, strong) LXUPnPDeviceService *AVTransport;
@property (nonatomic, strong) LXUPnPDeviceService *RenderingControl;

@property (nonatomic, copy) NSString *urlHeader;

- (void)setArray:(NSArray *)array;

@end

@interface LXUPnPDeviceService : NSObject

@property (nonatomic, copy) NSString *serviceType;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *controlURL;
@property (nonatomic, copy) NSString *eventSubURL;
@property (nonatomic, copy) NSString *SCPDURL;

- (void)setArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
