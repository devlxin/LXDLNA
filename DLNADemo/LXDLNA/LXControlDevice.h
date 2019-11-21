//
//  LXControlDevice.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *LXControlDevice_Unit_REL_TIME = @"REL_TIME";
static NSString *LXControlDevice_Unit_TRACK_NR = @"TRACK_NR";

@class LXUPnPDevice, LXUPnPTransportInfo, LXUPnPAVPositionInfo;

@protocol LXControlDeviceDelegate <NSObject>

@required
- (void)lx_setAVTransportURLReponse;
- (void)lx_getTransportInfoResponse:(LXUPnPTransportInfo *)transportInfo;

@optional
- (void)lx_playResponse;
- (void)lx_pauseResponse;
- (void)lx_stopResponse;
- (void)lx_seekResponse;
- (void)lx_previousResponse;
- (void)lx_nextResponse;
- (void)lx_setVolumeResponse;
- (void)lx_getVolumeResponse:(NSString *)volume;
- (void)lx_getPositionInfoResponse:(LXUPnPAVPositionInfo *)info;
- (void)lx_setNextAVTransportURLResponse;
- (void)lx_undefinedResponse:(NSString *)responseXML;

@end

/// 基于DLNA实现iOS，Android投屏：SOAP控制UPnP设备
/// https://eliyar.biz/DLNA_with_iOS_Android_Part_2_Control_Using_SOAP/
@interface LXControlDevice : NSObject

@property (nonatomic, strong) LXUPnPDevice *device;

@property (nonatomic, weak) id<LXControlDeviceDelegate> delegate;

- (instancetype)initWithDevice:(LXUPnPDevice *)device;

/// 设置当前播放地址
/// @param url  当前播放地址
- (void)setAVTransportURL:(NSString *)url;
/// 设置下一播放地址
/// @param nextUrl  下一播放地址
- (void)setNextAVTransportURL:(NSString *)nextUrl;

/// 播放
- (void)play;
/// 暂停
- (void)pause;
/// 停止
- (void)stop;
/// 下一个
- (void)next;
/// 上一个
- (void)previous;

/// 跳转到特定进度
/// @param time  时间进度(秒)
- (void)seekToTime:(float)time;
/// 跳转增量
/// @param increTime  时间增量(秒)，例如：-5，5
- (void)seekToTimeIncre:(float)increTime;
/// 跳转至特定进度或视频
/// @param target  目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR
/// @param unit  REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）
- (void)seekToTartget:(NSString *)target unit:(NSString *)unit;

/// 设置音量
/// @param volume  音量(0-100)
- (void)setVolume:(int)volume;
/// 设置音量增量
/// @discussion  部分电视机型初次获取到当前音量为100，并且只能将真实音量设置到20(比如创维)，建议增量为5(参考爱奇艺的解决方式)
///                   在此LXDLNA解决方式为：初次获取到音量为100时，默认其获取不到真实设备音量，将其音量初始化为20(真实音量为5)
/// @param volumeIncre  音量增量，例如：-5，5
- (void)setVolumeIncre:(int)volumeIncre;
/// 获取音量，音量通过Delegate返回
- (void)getVolume;

/// 获取播放状态，状态通过Delegate返回
- (void)getTransportInfo;
/// 获取播放进度，进度通过Delegate返回
- (void)getPositionInfo;

@end

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
