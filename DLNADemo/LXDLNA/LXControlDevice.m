//
//  LXControlDevice.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "LXControlDevice.h"
#import "GDataXMLNode.h"
#import "LXUPnPDevice.h"

typedef struct {
    unsigned int isExistSetAVTransportURLReponseDelegate:1;
    unsigned int isExistGetTransportInfoResponseDelegate:1;
    unsigned int isExistPlayResponseDelegate:1;
    unsigned int isExistPauseResponseDelegate:1;
    unsigned int isExistStopResponseDelegate:1;
    unsigned int isExistSeekResponseDelegate:1;
    unsigned int isExistPreviousResponseDelegate:1;
    unsigned int isExistNextResponseDelegate:1;
    unsigned int isExistSetVolumeResponseDelegate:1;
    unsigned int isExistGetVolumeResponseDelegate:1;
    unsigned int isExistGetPositionInfoResponseDelegate:1;
    unsigned int isExistSetNextAVTransportURLResponseDelegate:1;
    unsigned int isExistUndefinedResponseDelegate:1;
} LXControlDeviceDelegateFlags;

static NSString *LXControlDevice_Action_SetAVTransportURI = @"SetAVTransportURI";
static NSString *LXControlDevice_Action_SetNextAVTransportURI = @"SetNextAVTransportURI";
static NSString *LXControlDevice_Action_Play = @"Play";
static NSString *LXControlDevice_Action_Pause = @"Pause";
static NSString *LXControlDevice_Action_Stop = @"Stop";
static NSString *LXControlDevice_Action_Next = @"Next";
static NSString *LXControlDevice_Action_Previous = @"Previous";
static NSString *LXControlDevice_Action_GetPositionInfo = @"GetPositionInfo";
static NSString *LXControlDevice_Action_GetTransportInfo = @"GetTransportInfo";
static NSString *LXControlDevice_Action_Seek = @"Seek";
static NSString *LXControlDevice_Action_GetVolume = @"GetVolume";
static NSString *LXControlDevice_Action_SetVolume = @"SetVolume";

@interface LXControlDevice() {
    void (^_getVolumeCompleteBlock)(int volume);
    NSTimer *_timer;
}

@property (nonatomic, assign) LXControlDeviceDelegateFlags delegateFlags;

@end

@implementation LXControlDevice

- (instancetype)initWithDevice:(LXUPnPDevice *)device {
    self = [super init];
    self.device = device;
    return self;
}

- (void)setDelegate:(id<LXControlDeviceDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateFlags.isExistSetAVTransportURLReponseDelegate = [_delegate respondsToSelector:@selector(lx_setAVTransportURLReponse)];
        _delegateFlags.isExistGetTransportInfoResponseDelegate = [_delegate respondsToSelector:@selector(lx_getTransportInfoResponse:)];
        _delegateFlags.isExistPlayResponseDelegate = [_delegate respondsToSelector:@selector(lx_playResponse)];
        _delegateFlags.isExistPauseResponseDelegate = [_delegate respondsToSelector:@selector(lx_pauseResponse)];
        _delegateFlags.isExistStopResponseDelegate = [_delegate respondsToSelector:@selector(lx_stopResponse)];
        _delegateFlags.isExistSeekResponseDelegate = [_delegate respondsToSelector:@selector(lx_seekResponse)];
        _delegateFlags.isExistPreviousResponseDelegate = [_delegate respondsToSelector:@selector(lx_previousResponse)];
        _delegateFlags.isExistNextResponseDelegate = [_delegate respondsToSelector:@selector(lx_nextResponse)];
        _delegateFlags.isExistSetVolumeResponseDelegate = [_delegate respondsToSelector:@selector(lx_setVolumeResponse)];
        _delegateFlags.isExistGetVolumeResponseDelegate = [_delegate respondsToSelector:@selector(lx_getVolumeResponse:)];
        _delegateFlags.isExistGetPositionInfoResponseDelegate = [_delegate respondsToSelector:@selector(lx_getPositionInfoResponse:)];
        _delegateFlags.isExistSetNextAVTransportURLResponseDelegate = [_delegate respondsToSelector:@selector(lx_setNextAVTransportURLResponse)];
        _delegateFlags.isExistUndefinedResponseDelegate = [_delegate respondsToSelector:@selector(lx_undefinedResponse:)];
    } else {
        _delegateFlags.isExistSetAVTransportURLReponseDelegate = 0;
        _delegateFlags.isExistGetTransportInfoResponseDelegate = 0;
        _delegateFlags.isExistPlayResponseDelegate = 0;
        _delegateFlags.isExistPauseResponseDelegate = 0;
        _delegateFlags.isExistStopResponseDelegate = 0;
        _delegateFlags.isExistSeekResponseDelegate = 0;
        _delegateFlags.isExistPreviousResponseDelegate = 0;
        _delegateFlags.isExistNextResponseDelegate = 0;
        _delegateFlags.isExistSetVolumeResponseDelegate = 0;
        _delegateFlags.isExistGetVolumeResponseDelegate = 0;
        _delegateFlags.isExistGetPositionInfoResponseDelegate = 0;
        _delegateFlags.isExistSetNextAVTransportURLResponseDelegate = 0;
        _delegateFlags.isExistUndefinedResponseDelegate = 0;
    }
}

#pragma mark AVTransport
- (void)setAVTransportURL:(NSString *)url {
    if (LXDLNA_kStringIsEmpty(url)) return;
    
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_SetAVTransportURI];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"CurrentURI" stringValue:url]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"CurrentURIMetaData" stringValue:@""]];
    [self _postAction:LXControlDevice_Action_SetAVTransportURI body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)setNextAVTransportURL:(NSString *)nextUrl {
    if (LXDLNA_kStringIsEmpty(nextUrl)) return;
    
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_SetNextAVTransportURI];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"NextURI" stringValue:nextUrl]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"NextURIMetaData" stringValue:@""]];
    [self _postAction:LXControlDevice_Action_SetNextAVTransportURI body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)play {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Play];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"Speed" stringValue:@"1"]];
    [self _postAction:LXControlDevice_Action_Play body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)pause {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Pause];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_Pause body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)stop {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Stop];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_Stop body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)next {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Next];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_Next body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)previous {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Previous];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_Previous body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

- (void)seekToTime:(float)time {
    if (time < 0) time = 0;
    [self seekToTartget:[self _getDurationTime:time] unit:LXControlDevice_Unit_REL_TIME];
}

- (void)seekToTartget:(NSString *)target unit:(NSString *)unit {
    if (![LXControlDevice_Unit_REL_TIME isEqualToString:unit] && ![LXControlDevice_Unit_TRACK_NR isEqualToString:unit]) return;
    
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_Seek];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"Target" stringValue:target]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"Unit" stringValue:unit]];
    [self _postAction:LXControlDevice_Action_Seek body:XMLElement serviceType:LXUPnPDevice_ServiceType_AVTransport];
}

#pragma mark RenderingControl
- (void)setVolume:(int)volume {
    if (volume < 0) volume = 0;
    
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_SetVolume];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"Channel" stringValue:@"Master"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"DesiredVolume" stringValue:[NSString stringWithFormat:@"%d", volume]]];
    [self _postAction:LXControlDevice_Action_SetVolume body:XMLElement serviceType:LXUPnPDevice_ServiceType_RenderingControl];
}

- (void)setVolumeIncre:(int)volumeIncre {
    __weak typeof(self) weakSelf = self;
    [self getVolume:^(int volume) {
        [weakSelf setVolume:volume + volumeIncre];
    }];
}

- (void)getVolume {
    [self getVolume:nil];
}

- (void)getVolume:(void (^)(int volume))complete {
    if (complete) _getVolumeCompleteBlock = complete;
    
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_GetVolume];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"Channel" stringValue:@"Master"]];
    [self _postAction:LXControlDevice_Action_GetVolume body:XMLElement serviceType:LXUPnPDevice_ServiceType_RenderingControl];
}

- (void)getTransportInfo {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_GetTransportInfo];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_GetTransportInfo body:XMLElement serviceType:LXUPnPDevice_ServiceType_RenderingControl];
}

- (void)getPositionInfo {
    NSString *name = [NSString stringWithFormat:@"u:%@", LXControlDevice_Action_GetPositionInfo];
    GDataXMLElement *XMLElement = [GDataXMLElement elementWithName:name];
    [XMLElement addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [self _postAction:LXControlDevice_Action_GetPositionInfo body:XMLElement serviceType:LXUPnPDevice_ServiceType_RenderingControl];
}

#pragma mark - timer
- (void)startGetPositionInfoTimer {
    [self stopGetPositionInfoTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getPositionInfo) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopGetPositionInfoTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - post response
- (void)_postResponse:(NSData *)data {
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            for (int i = 0; i < needArr.count; i++) {
                GDataXMLElement *ele = [needArr objectAtIndex:i];
                if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
                    if (self.delegateFlags.isExistSetAVTransportURLReponseDelegate) {
                        [self.delegate lx_setAVTransportURLReponse];
                    }
                    [self getTransportInfo];
                } else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]) {
                    if (self.delegateFlags.isExistSetNextAVTransportURLResponseDelegate) {
                        [self.delegate lx_setNextAVTransportURLResponse];
                    }
                } else if ([[ele name] hasSuffix:@"PlayResponse"]) {
                    if (self.delegateFlags.isExistPlayResponseDelegate) {
                        [self.delegate lx_playResponse];
                    }
                } else if ([[ele name] hasSuffix:@"PauseResponse"]) {
                    if (self.delegateFlags.isExistPauseResponseDelegate) {
                        [self.delegate lx_pauseResponse];
                    }
                } else if ([[ele name] hasSuffix:@"StopResponse"]){
                    if (self.delegateFlags.isExistStopResponseDelegate) {
                        [self.delegate lx_stopResponse];
                    }
                } else if ([[ele name] hasSuffix:@"SeekResponse"]) {
                    if (self.delegateFlags.isExistSeekResponseDelegate) {
                        [self.delegate lx_seekResponse];
                    }
                } else if ([[ele name] hasSuffix:@"NextResponse"]) {
                    if (self.delegateFlags.isExistNextResponseDelegate) {
                        [self.delegate lx_nextResponse];
                    }
                } else if ([[ele name] hasSuffix:@"PreviousResponse"]) {
                    if (self.delegateFlags.isExistPreviousResponseDelegate) {
                        [self.delegate lx_previousResponse];
                    }
                } else if ([[ele name] hasSuffix:@"SetVolumeResponse"]) {
                    if (self.delegateFlags.isExistSetVolumeResponseDelegate) {
                        [self.delegate lx_setVolumeResponse];
                    }
                } else if ([[ele name] hasSuffix:@"GetVolumeResponse"]) {
                    if (self.delegateFlags.isExistGetVolumeResponseDelegate) {
                        for (int j = 0; j < [ele children].count; j++) {
                            GDataXMLElement *eleXml = [[ele children] objectAtIndex:j];
                            if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
                                [self.delegate lx_getVolumeResponse:[eleXml stringValue]];
                            }
                        }
                    }
                    if (_getVolumeCompleteBlock) {
                        for (int j = 0; j < [ele children].count; j++) {
                            GDataXMLElement *eleXml = [[ele children] objectAtIndex:j];
                            if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
                                _getVolumeCompleteBlock([eleXml stringValue].intValue);
                            }
                        }
                    }
                } else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]) {
                    if (self.delegateFlags.isExistGetPositionInfoResponseDelegate) {
                        LXUPnPAVPositionInfo *info = [[LXUPnPAVPositionInfo alloc] init];
                        [info setArray:[ele children]];
                        [self.delegate lx_getPositionInfoResponse:info];
                    }
                } else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]) {
                    if (self.delegateFlags.isExistGetTransportInfoResponseDelegate) {
                        LXUPnPTransportInfo *info = [[LXUPnPTransportInfo alloc] init];
                        [info setArray:[ele children]];
                        [self.delegate lx_getTransportInfoResponse:info];
                    }
                } else {
                    if (self.delegateFlags.isExistUndefinedResponseDelegate) {
                        [self.delegate lx_undefinedResponse:[ele XMLString]];
                    }
                }
            }
        } else {
            if (self.delegateFlags.isExistUndefinedResponseDelegate) {
                [self.delegate lx_undefinedResponse:[xmlEle XMLString]];
            }
        }
    }
}

#pragma mark - post data
- (void)_postAction:(NSString *)action body:(GDataXMLElement *)xmlBody serviceType:(NSString *)serviceType {
    NSString *url = [self _getPostURL:serviceType]; if (LXDLNA_kStringIsEmpty(url)) return;
    NSString *postXMLString = [self _getPostXMLString:xmlBody serviceType:serviceType]; if (LXDLNA_kStringIsEmpty(postXMLString)) return;
    NSString *SOAPAction = [self _getSOAPAction:action serviceType:serviceType]; if (LXDLNA_kStringIsEmpty(SOAPAction)) return;
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:SOAPAction forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [postXMLString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            if (self.delegateFlags.isExistUndefinedResponseDelegate) {
                [self.delegate lx_undefinedResponse:error.localizedDescription];
            }
            return;
        } else {
            [self _postResponse:data];
        }
    }];
    [dataTask resume];
}

- (NSString *)_getPostURL:(NSString *)serviceType {
    if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_AVTransport]) {
        if ([self.device.AVTransport.controlURL hasPrefix:@"/"]) {
            return [NSString stringWithFormat:@"%@%@", self.device.urlHeader, self.device.AVTransport.controlURL];
        }else{
            return [NSString stringWithFormat:@"%@/%@", self.device.urlHeader, self.device.AVTransport.controlURL];
        }
    } else if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_RenderingControl]) {
        if ([self.device.RenderingControl.controlURL hasPrefix:@"/"]) {
            return [NSString stringWithFormat:@"%@%@", self.device.urlHeader, self.device.RenderingControl.controlURL];
        } else {
            return [NSString stringWithFormat:@"%@/%@", self.device.urlHeader, self.device.RenderingControl.controlURL];
        }
    }
    return nil;
}

- (NSString *)_getPostXMLString:(GDataXMLElement *)xmlBody serviceType:(NSString *)serviceType {
    GDataXMLElement *xmlEle = [GDataXMLElement elementWithName:@"s:Envelope"];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:serviceType]];
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [command addChild:xmlBody];
    [xmlEle addChild:command];
    return xmlEle.XMLString;
}

- (NSString *)_getSOAPAction:(NSString *)action serviceType:(NSString *)serviceType {
    if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_AVTransport]) {
        return [NSString stringWithFormat:@"\"%@#%@\"", LXUPnPDevice_ServiceType_AVTransport, action];
    } else if ([serviceType isEqualToString:LXUPnPDevice_ServiceType_RenderingControl]) {
        return [NSString stringWithFormat:@"\"%@#%@\"", LXUPnPDevice_ServiceType_RenderingControl, action];
    }
    return nil;
}

#pragma mark - private method
- (NSString *)_getDurationTime:(float)timeValue {
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            (int)(timeValue / 3600.0),
            (int)(fmod(timeValue, 3600.0) / 60.0),
            (int)fmod(timeValue, 60.0)];
}

#pragma mark - life cycle
- (void)dealloc {
    [self stopGetPositionInfoTimer];
}

@end

@implementation LXUPnPTransportInfo

- (void)setArray:(NSArray *)array {
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"CurrentTransportState"]) {
                self.currentTransportState = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"CurrentTransportStatus"]) {
                self.currentTransportStatus = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"CurrentSpeed"]) {
                self.currentSpeed = [needEle stringValue];
            }
        }
    }
}

@end

@implementation LXUPnPAVPositionInfo

- (void)setArray:(NSArray *)array {
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"TrackDuration"]) {
                self.trackDuration = [self _durationTime:[needEle stringValue]];
            }
            if ([needEle.name isEqualToString:@"RelTime"]) {
                self.relTime = [self _durationTime:[needEle stringValue]];
            }
            if ([needEle.name isEqualToString:@"AbsTime"]) {
                self.absTime = [self _durationTime:[needEle stringValue]];
            }
        }
    }
}

- (float)_durationTime:(NSString *)timeStr {
    NSArray *timeStrings = [timeStr componentsSeparatedByString:@":"];
    int timeStringsCount = (int)[timeStrings count];
    if (timeStringsCount < 3)
        return -1.0f;
    float durationTime = 0.0;
    for (int n = 0; n<timeStringsCount; n++) {
        NSString *timeString = [timeStrings objectAtIndex:n];
        int timeIntValue = [timeString intValue];
        switch (n) {
            case 0: // HH
                durationTime += timeIntValue * (60 * 60);
                break;
            case 1: // MM
                durationTime += timeIntValue * 60;
                break;
            case 2: // SS
                durationTime += timeIntValue;
                break;
            case 3: // .F?
                durationTime += timeIntValue * 0.1;
                break;
            default:
                break;
        }
    }
    return durationTime;
}

@end
