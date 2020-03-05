//
//  DLNAManager.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCUPnPDevice;

@protocol DLNAManagerDelegate <NSObject>

@optional
// DLNA局域网搜索设备结果回调
- (void)dlnaManagerDeviceSearchResult:(NSArray <CCUPnPDevice *> *)devicesArray;
- (void)dlnaManagerSearchOutTime;
// 投屏成功开始播放
- (void)dlnaManagerResponseStartPlay;
- (void)dlnaManagerResponsePause;
- (void)dlnaManagerResponseNext;

@end

@interface DLNAManager : NSObject

@property(nonatomic, weak) id <DLNAManagerDelegate> delegate;

@property(nonatomic, strong) CCUPnPDevice *device;

@property(nonatomic, copy) NSString *playUrl;

@property(nonatomic, assign) NSInteger searchOutTime;

+ (instancetype)sharedDLNAManager;
// 搜设备
- (void)startSearch;
- (void)stopSearch;
// DLNA投屏
- (void)startDLNAPlay;
// DLNA投屏(首先停止)---投屏不了可以使用这个方法
- (void)startDLNAPlayAfterStopPreviouslyForce;
// 退出DLNA
- (void)endDLNAPlay;

#pragma mark - 控制逻辑
// 播放
- (void)dlnaPlay;
// 暂停
- (void)dlnaPause;
// 设置音量volume建议传0-100之间字符串
- (void)volumeChanged:(NSString *)volume;
// 设置播放进度 seek单位是秒
- (void)seekChanged:(NSInteger)seek;
// 播放切集
- (void)playTheURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
