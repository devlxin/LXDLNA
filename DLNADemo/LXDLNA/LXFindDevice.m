//
//  LXFindDevice.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "LXFindDevice.h"
#import <GCDAsyncUdpSocket.h>
#import "LXUPnPDevice.h"
#import "GDataXMLNode.h"

typedef struct {
    unsigned int isExistUPnPDeviceChangedDelegate:1;
    unsigned int isExistUPnPDeviceFindFaildDelegate:1;
} LXFindDeviceDelegateFlags;

static NSString *LXSSDP_IPv4Address = @"239.255.255.250";
static uint16_t LXSSDP_IPv4Port = 1900;

static NSString *LXSSDP_IPv6Address = @"FF0x::C";

@interface LXFindDevice() <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSMutableDictionary *deviceDict;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t queue;
#else
@property (nonatomic, assign) dispatch_queue_t queue;
#endif

@property (nonatomic, assign) LXFindDeviceDelegateFlags delegateFlags;

@end

@implementation LXFindDevice

- (instancetype)init {
    self = [super init];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    self.deviceDict = @{}.mutableCopy;
    self.queue = dispatch_queue_create("com.devlxin.lxdlna", DISPATCH_QUEUE_SERIAL);
    return self;
}

+ (instancetype)sharedInstance {
    static LXFindDevice *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LXFindDevice alloc] init];
    });
    return instance;
}

- (void)setDelegate:(id<LXFindDeviceDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateFlags.isExistUPnPDeviceChangedDelegate = [_delegate respondsToSelector:@selector(lx_UPnPDeviceChanged:)];
        _delegateFlags.isExistUPnPDeviceFindFaildDelegate = [_delegate respondsToSelector:@selector(lx_UPnPDeviceFindFaild:)];
    } else {
        _delegateFlags.isExistUPnPDeviceChangedDelegate = 0;
        _delegateFlags.isExistUPnPDeviceFindFaildDelegate = 0;
    }
}

- (void)startFindDevice {
    NSError *error = nil;
    if (![self.udpSocket bindToPort:LXSSDP_IPv4Port error:&error]) {
        if (self.delegateFlags.isExistUPnPDeviceFindFaildDelegate) {
            [self.delegate lx_UPnPDeviceFindFaild:error];
        }
    }
    if (![self.udpSocket beginReceiving:&error]) {
        if (self.delegateFlags.isExistUPnPDeviceFindFaildDelegate) {
            [self.delegate lx_UPnPDeviceFindFaild:error];
        }
    }
    if (![self.udpSocket joinMulticastGroup:LXSSDP_IPv4Address error:&error]) {
        if (self.delegateFlags.isExistUPnPDeviceFindFaildDelegate) {
            [self.delegate lx_UPnPDeviceFindFaild:error];
        }
    }
    [self.deviceDict removeAllObjects];
    
    if (self.delegateFlags.isExistUPnPDeviceChangedDelegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate lx_UPnPDeviceChanged:self.deviceDict.allValues];
        });
    }

    NSString *dataString = [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nHOST: %@:%d\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: %@\r\nUSER-AGENT: iOS UPnP/1.1\r\n\r\n", LXSSDP_IPv4Address, LXSSDP_IPv4Port, @"urn:schemas-upnp-org:service:AVTransport:1"];
    [self.udpSocket sendData:[dataString dataUsingEncoding:NSUTF8StringEncoding] toHost:LXSSDP_IPv4Address port:LXSSDP_IPv4Port withTimeout:-1 tag:1];
}

- (void)stopFindDevice {
    [self.udpSocket close];
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    [self _handlerReceiveData:data];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {}

#pragma mark - handle receive data
- (void)_handlerReceiveData:(NSData *)data {
    @autoreleasepool {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([dataString hasPrefix:@"NOTIFY * HTTP/1.1"]) { // 设备主动通知
            NSString *serviceType = [self _headerValueForKey:@"NT:" inData:dataString];
            if ([LXUPnPDevice_ServiceType_AVTransport isEqualToString:serviceType]) {
                NSString *usn = [self _headerValueForKey:@"USN:" inData:dataString];
                NSString *location = [self _headerValueForKey:@"Location:" inData:dataString];
                NSString *ssdp = [self _headerValueForKey:@"NTS:" inData:dataString];
                if (LXDLNA_kStringIsEmpty(usn)) return;
                if (LXDLNA_kStringIsEmpty(location)) return;
                if (LXDLNA_kStringIsEmpty(ssdp)) return;
                if ([ssdp isEqualToString:@"ssdp:alive"]) { // 设备可用
                    dispatch_async(self.queue, ^{
                        if (![self.deviceDict objectForKey:usn]) {
                            LXUPnPDevice *device = [self getDeviceInfo:usn location:location];
                            if (device) {
                                [self.deviceDict setValue:device forKey:usn];
                                if (self.delegateFlags.isExistUPnPDeviceChangedDelegate) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.delegate lx_UPnPDeviceChanged:self.deviceDict.allValues];
                                    });
                                }
                            }
                        }
                    });
                } else if ([ssdp isEqualToString:@"ssdp:byebye"]) { // 设备不可用
                    dispatch_async(self.queue, ^{
                        if ([self.deviceDict objectForKey:usn]) {
                            [self.deviceDict removeObjectForKey:usn];
                            if (self.delegateFlags.isExistUPnPDeviceChangedDelegate) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate lx_UPnPDeviceChanged:self.deviceDict.allValues];
                                });
                            }
                        }
                    });
                }
            }
        } else if ([dataString hasPrefix:@"HTTP/1.1 200 OK"]) { // 搜索响应
            NSString *usn = [self _headerValueForKey:@"USN:" inData:dataString];
            NSString *location = [self _headerValueForKey:@"Location:" inData:dataString];
            if (LXDLNA_kStringIsEmpty(usn)) return;
            if (LXDLNA_kStringIsEmpty(location)) return;
            dispatch_async(self.queue, ^{
                if (![self.deviceDict objectForKey:usn]) {
                    LXUPnPDevice *device = [self getDeviceInfo:usn location:location];
                    if (device) {
                        [self.deviceDict setValue:device forKey:usn];
                        if (self.delegateFlags.isExistUPnPDeviceChangedDelegate) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate lx_UPnPDeviceChanged:self.deviceDict.allValues];
                            });
                        }
                    }
                }
            });
        }
    }
}

- (LXUPnPDevice *)getDeviceInfo:(NSString *)usn location:(NSString *)location {
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    
    __block LXUPnPDevice *device = nil;
    __weak typeof(self) weakSelf = self;
    NSURL *URL = [NSURL URLWithString:location];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    request.HTTPMethod = @"GET";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (weakSelf.delegateFlags.isExistUPnPDeviceFindFaildDelegate) {
                [weakSelf.delegate lx_UPnPDeviceFindFaild:error];
            }
        } else {
            if (response != nil && data != nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if ([httpResponse statusCode] == 200) {
                    device = [[LXUPnPDevice alloc] init];
                    device.uuid = usn;
                    device.location = URL;
                    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
                    GDataXMLElement *xmlEle = [xmlDoc rootElement];
                    NSArray *xmlArray = [xmlEle children];
                    for (int i = 0; i < [xmlArray count]; i++) {
                        GDataXMLElement *element = [xmlArray objectAtIndex:i];
                        if ([[element name] isEqualToString:@"device"]) {
                            [device setArray:[element children]];
                            continue;
                        }
                    }
                }
            }
        }
        dispatch_semaphore_signal(lock);
    }] resume];
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return device;
}

#pragma mark - private method
- (NSString *)_headerValueForKey:(NSString *)key inData:(NSString *)data {
    NSString *str = [NSString stringWithFormat:@"%@", data];
    NSRange keyRange = [str rangeOfString:key options:NSCaseInsensitiveSearch];
    if (keyRange.location == NSNotFound) {
        return @"";
    }
    str = [str substringFromIndex:keyRange.location + keyRange.length];
    NSRange enterRange = [str rangeOfString:@"\r\n"];
    NSString *value = [[str substringToIndex:enterRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value;
}

@end
