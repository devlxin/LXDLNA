//
//  LXSubscribeDevice.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/21.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "LXSubscribeDevice.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import "GDataXMLNode.h"
#import "LXUPnPDevice.h"

typedef struct {
    unsigned int isExistSubcirbeTransportStateCallbackDelegate:1;
    unsigned int isExistSubcirbeRelativeTimePositionCallbackDelegate:1;
    unsigned int isExistSubcirbeVolumeCallbackDelegate:1;
} LXSubscribeDeviceDelegateFlags;

@interface LXSubscribeDevice()

@property (nonatomic, strong) GCDWebServer *webServer;

@property (nonatomic, strong) NSMutableDictionary *sidDict;
@property (nonatomic, assign) LXSubscribeDeviceDelegateFlags delegateFlags;

@end

@implementation LXSubscribeDevice

- (instancetype)init {
    self = [super init];
    self.isRelativeTimePositionEnabled = NO;
    self.sidDict = @{}.mutableCopy;
    return self;
}

- (instancetype)initWithDevice:(LXUPnPDevice *)device {
    self = [super init];
    self.device = device;
    self.isRelativeTimePositionEnabled = NO;
    self.sidDict = @{}.mutableCopy;
    return self;
}

- (void)setDelegate:(id<LXSubscribeDeviceDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateFlags.isExistSubcirbeTransportStateCallbackDelegate = [_delegate respondsToSelector:@selector(lx_subcirbeTransportStateCallback:)];
        _delegateFlags.isExistSubcirbeRelativeTimePositionCallbackDelegate = [_delegate respondsToSelector:@selector(lx_subcirbeRelativeTimePositionCallback:)];
        _delegateFlags.isExistSubcirbeVolumeCallbackDelegate = [_delegate respondsToSelector:@selector(lx_subcirbeVolumeCallback:)];
    } else {
        _delegateFlags.isExistSubcirbeTransportStateCallbackDelegate = 0;
        _delegateFlags.isExistSubcirbeRelativeTimePositionCallbackDelegate = 0;
        _delegateFlags.isExistSubcirbeVolumeCallbackDelegate = 0;
    }
}

- (void)sendSubcirbeWithTime:(int)time serviceType:(NSString *)serviceType {
    if (_webServer.isRunning && [self.sidDict.allKeys containsObject:serviceType]) {
        return;
    }
    
    if (self.sidDict && [self.sidDict.allValues containsObject:serviceType]) {
        [self.sidDict removeObjectForKey:serviceType];
    }
    
    if (time <= 0) time = 3600;
    
    NSString *callbackUrlStr = [self _startWebServer];
    [self _post:callbackUrlStr time:time serviceType:serviceType];
}

- (void)contractSubscirbeWithTime:(int)time serviceType:(NSString *)serviceType {
    if (![self.sidDict.allKeys containsObject:serviceType]) return;
    
    NSString *serverUrlStr = self.webServer.serverURL.absoluteString;
    NSString *callbackUrlStr = [NSString stringWithFormat:@"%@dlna/callback", serverUrlStr];
    [self _post:callbackUrlStr time:time serviceType:serviceType];
}

- (void)removeSubscirbeWithServiceType:(NSString *)serviceType {
    if (![self.sidDict.allKeys containsObject:serviceType]) return;
    
    NSString *serverUrlStr = self.webServer.serverURL.absoluteString;
    NSString *callbackUrlStr = [NSString stringWithFormat:@"%@dlna/callback", serverUrlStr];
    [self _post:callbackUrlStr time:0 serviceType:serviceType];
}

#pragma mark - server callback
- (NSString *)_startWebServer {
    [self _stopWebServer];
    
    self.webServer = [[GCDWebServer alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.webServer addHandlerForMethod:@"NOTIFY" pathRegex:@"dlna/callback" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerDataRequest * _Nonnull request) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (request.hasBody && request.data) {
            if ([request.headers isKindOfClass:[NSDictionary class]]) {
                NSString *sid = request.headers[@"SID"];
                if ([strongSelf.sidDict.allValues containsObject:sid]) {
                    if ([request isKindOfClass:[GCDWebServerDataRequest class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf _handleResponse:request.data];
                        });
                    }
                }
            }
        }
        GCDWebServerResponse *response = [[GCDWebServerResponse alloc] initWithStatusCode:200];
        return response;
    }];
    [self.webServer start];
    NSString *serverUrlStr = self.webServer.serverURL.absoluteString;
    return [NSString stringWithFormat:@"%@dlna/callback", serverUrlStr];
}

- (void)_handleResponse:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [self _retransfer:string];
    NSData *xmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *propertyElement = [bigArray objectAtIndex:i];
        if ([[propertyElement name] hasSuffix:@"property"]) {
            NSArray *propertyArray = [propertyElement children];
            for (int i = 0; i < [propertyArray count]; i++) {
                GDataXMLElement *lastChangeElement = [propertyArray objectAtIndex:i];
                if ([[lastChangeElement name] hasSuffix:@"LastChange"]) {
                    NSArray *lastChangeArray = [lastChangeElement children];
                    for (int i = 0; i < [lastChangeArray count]; i++) {
                        GDataXMLElement *eventElement = [lastChangeArray objectAtIndex:i];
                        if ([[eventElement name] hasSuffix:@"Event"]) {
                            NSArray *eventArray = [eventElement children];
                            for (int i = 0; i < [eventArray count]; i++) {
                                GDataXMLElement *instanceIDElement = [eventArray objectAtIndex:i];
                                if ([[instanceIDElement name] hasSuffix:@"InstanceID"]) {
                                    NSArray *instanceIDElementArray = [instanceIDElement children];
                                    for (int i = 0; i < [instanceIDElementArray count]; i++) {
                                        GDataXMLElement *needElement = [instanceIDElementArray objectAtIndex:i];
                                        if ([[needElement name] isEqualToString:@"TransportState"]) {
                                            NSString *transportState = [[needElement attributeForName:@"val"] stringValue];
                                            if (self.delegateFlags.isExistSubcirbeTransportStateCallbackDelegate) {
                                                [self.delegate lx_subcirbeTransportStateCallback:transportState];
                                            }
                                        }
                                        if ([[needElement name] isEqualToString:@"RelativeTimePosition"]) {
                                            NSString *relativeTimePosition =  [[needElement attributeForName:@"val"] stringValue];
                                            if (self.delegateFlags.isExistSubcirbeRelativeTimePositionCallbackDelegate) {
                                                [self.delegate lx_subcirbeRelativeTimePositionCallback:relativeTimePosition];
                                            }
                                            self.isRelativeTimePositionEnabled = YES;
                                        }
                                        if ([[needElement name] isEqualToString:@"Volume"]) {
                                            NSString *volume =  [[needElement attributeForName:@"val"] stringValue];
                                            if (self.delegateFlags.isExistSubcirbeVolumeCallbackDelegate) {
                                                [self.delegate lx_subcirbeVolumeCallback:volume.intValue];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)_stopWebServer {
    if (self.webServer) {
        if (self.webServer.isRunning) {
            [self.webServer stop];
            [self.webServer removeAllHandlers];
        }
        self.webServer = nil;
    }
}

#pragma mark - post data
- (void)_post:(NSString *)callbackUrlStr time:(int)time serviceType:(NSString *)serviceType {
    NSString *url = [self _getPostURL:serviceType]; if (LXDLNA_kStringIsEmpty(url)) return;
    
    NSURL *URL = [NSURL URLWithString:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    if (time > 0) { // time<=0表示退订
        [request addValue:[NSString stringWithFormat:@"Second-%d", time] forHTTPHeaderField:@"TIMEOUT"];
    } else {
        request.HTTPMethod = @"UNSUBSCRIBE";
    }
    if ([self.sidDict.allKeys containsObject:serviceType]) {
        NSString *sid = [self.sidDict valueForKey:serviceType];
        [request addValue:sid forHTTPHeaderField:@"SID"];
    }
    if (![self.sidDict.allKeys containsObject:serviceType]) {
        request.HTTPMethod = @"SUBSCRIBE";
        NSString *version = [UIDevice currentDevice].systemVersion;
        NSString *userAgent = [NSString stringWithFormat:@"iOS/%@ UPnP/1.1 SCDLNA/1.0", version];
        [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
        [request addValue:[NSString stringWithFormat:@"<%@>", callbackUrlStr] forHTTPHeaderField:@"CALLBACK"];
        [request addValue:@"upnp:event" forHTTPHeaderField:@"NT"];
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            if ([self.sidDict.allKeys containsObject:serviceType]) {
                if (time <= 0) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(lx_removeSubscirbeSuccessOrFail:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate lx_removeSubscirbeSuccessOrFail:NO];
                        });
                    }
                } else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(lx_contractSubscirbeSuccessOrFail:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate lx_contractSubscirbeSuccessOrFail:NO];
                        });
                    }
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(lx_subcirbeSuccessOrFail:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate lx_subcirbeSuccessOrFail:NO];
                    });
                }
            }
            return;
        } else {
            if ([self.sidDict.allKeys containsObject:serviceType]) {
                if (time <= 0) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(lx_removeSubscirbeSuccessOrFail:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate lx_removeSubscirbeSuccessOrFail:YES];
                        });
                        [self.sidDict removeObjectForKey:serviceType];
                    }
                } else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(lx_contractSubscirbeSuccessOrFail:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate lx_contractSubscirbeSuccessOrFail:YES];
                        });
                    }
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(lx_subcirbeSuccessOrFail:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate lx_subcirbeSuccessOrFail:YES];
                    });
                }
            }
        }
        if (time > 0) {
            NSHTTPURLResponse *resultResponse = (NSHTTPURLResponse*)response;
            NSString *sid = [resultResponse.allHeaderFields valueForKey:@"SID"];
            if(!LXDLNA_kStringIsEmpty(sid)) {
                 [self.sidDict setValue:sid forKey:serviceType];
             }
        }
    }];
    [dataTask resume];
}

- (NSString *)_getPostURL:(NSString *)serviceType {
    if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_AVTransport]) {
        if ([self.device.AVTransport.eventSubURL hasPrefix:@"/"]) {
            return [NSString stringWithFormat:@"%@%@", self.device.urlHeader, self.device.AVTransport.eventSubURL];
        }else{
            return [NSString stringWithFormat:@"%@/%@", self.device.urlHeader, self.device.AVTransport.eventSubURL];
        }
    } else if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_RenderingControl]) {
        if ([self.device.RenderingControl.eventSubURL hasPrefix:@"/"]) {
            return [NSString stringWithFormat:@"%@%@", self.device.urlHeader, self.device.RenderingControl.eventSubURL];
        } else {
            return [NSString stringWithFormat:@"%@/%@", self.device.urlHeader, self.device.RenderingControl.eventSubURL];
        }
    }
    return nil;
}

#pragma mark - private method
- (NSString*)_retransfer:(NSString*)string {
    if(LXDLNA_kStringIsEmpty(string)) return nil;
    NSString *result = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    result = [result stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    result = [result stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    return result;
}

#pragma mark - life cycle
- (void)dealloc {
    [self _stopWebServer];
}

@end
