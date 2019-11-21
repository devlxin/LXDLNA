//
//  LXUPnPStatusInfo.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/21.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *LXUPnPTransportInfo_Status_Playing = @"PLAYING";
static NSString *LXUPnPTransportInfo_Status_Transitioning = @"TRANSITIONING";
static NSString *LXUPnPTransportInfo_Status_Stopped = @"STOPPED";
static NSString *LXUPnPTransportInfo_Status_Paused = @"PAUSED_PLAYBACK";
static NSString *LXUPnPTransportInfo_Status_NoMediaPresent = @"NO_MEDIA_PRESENT";

/// 播放状态信息
@interface LXUPnPTransportInfo : NSObject

@property (nonatomic, copy) NSString *currentTransportState;
@property (nonatomic, copy) NSString *currentTransportStatus;
@property (nonatomic, copy) NSString *currentSpeed;

- (void)setArray:(NSArray *)array;

@end

/// 播放进度信息
@interface LXUPnPAVPositionInfo : NSObject

@property (nonatomic, assign) float trackDuration;
@property (nonatomic, assign) float absTime;
@property (nonatomic, assign) float relTime;

- (void)setArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
