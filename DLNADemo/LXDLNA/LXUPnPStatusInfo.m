//
//  LXUPnPStatusInfo.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/21.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "LXUPnPStatusInfo.h"
#import "GDataXMLNode.h"

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
