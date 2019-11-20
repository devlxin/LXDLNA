//
//  LXUPnPDevice.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "LXUPnPDevice.h"
#import "GDataXMLNode.h"

@implementation LXUPnPDevice

- (LXUPnPDeviceService *)AVTransport {
    if (!_AVTransport) {
        _AVTransport = [[LXUPnPDeviceService alloc] init];
    }
    return _AVTransport;
}

- (LXUPnPDeviceService *)RenderingControl {
    if (!_RenderingControl) {
        _RenderingControl = [[LXUPnPDeviceService alloc] init];
    }
    return _RenderingControl;
}

- (void)setArray:(NSArray *)array {
    @autoreleasepool {
        for (int j = 0; j < [array count]; j++) {
            GDataXMLElement *ele = [array objectAtIndex:j];
            if ([ele.name isEqualToString:@"friendlyName"]) {
                self.friendlyName = [ele stringValue];
            }
            if ([ele.name isEqualToString:@"modelName"]) {
                self.modelName = [ele stringValue];
            }
            if ([ele.name isEqualToString:@"serviceList"]) {
                NSArray *serviceListArray = [ele children];
                for (int k = 0; k < [serviceListArray count]; k++) {
                    GDataXMLElement *listEle = [serviceListArray objectAtIndex:k];
                    if ([listEle.name isEqualToString:@"service"]) {
                        NSString *serviceString = [listEle stringValue];
                        if ([serviceString rangeOfString:LXUPnPDevice_ServiceType_AVTransport].location != NSNotFound || [serviceString rangeOfString:LXUPnPDevice_ServiceId_AVTransport].location != NSNotFound) {
                            [self.AVTransport setArray:[listEle children]];
                        } else if ([serviceString rangeOfString:LXUPnPDevice_ServiceType_RenderingControl].location != NSNotFound || [serviceString rangeOfString:LXUPnPDevice_ServiceId_RenderingControl].location != NSNotFound) {
                            [self.RenderingControl setArray:[listEle children]];
                        }
                    }
                }
                continue;
            }
        }
    }
}

- (NSString *)urlHeader {
    if (!_urlHeader) {
        _urlHeader = [NSString stringWithFormat:@"%@://%@:%@", [self.location scheme], [self.location host], [self.location port]];
    }
    return _urlHeader;
}

@end

@implementation LXUPnPDeviceService

- (void)setArray:(NSArray *)array {
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"serviceType"]) {
                self.serviceType = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"serviceId"]) {
                self.serviceId = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"controlURL"]) {
                self.controlURL = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"eventSubURL"]) {
                self.eventSubURL = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"SCPDURL"]) {
                self.SCPDURL = [needEle stringValue];
            }
        }
    }
}

@end
