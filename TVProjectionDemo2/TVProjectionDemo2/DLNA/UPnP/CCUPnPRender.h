//
//  CCUPnPRender.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCUPnPTransportInfo, CCUPnPPositionInfo, CCUPnPDevice;

// 响应解析回调协议
@protocol CCUPnPRenderResponseDelegate <NSObject>

@optional
- (void)upnpResponseSetAVTransportURI;                              // 设置url响应
- (void)upnpResponseGetTransportInfo:(CCUPnPTransportInfo *)info;   // 获取播放状态
- (void)upnpResponseUndefined:(NSString *)resXML postXML:(NSString *)postXML;
- (void)upnpResponsePlay;                                           // 播放响应
- (void)upnpResponsePause;                                          // 暂停响应
- (void)upnpResponseStop;                                           // 停止投屏
- (void)upnpResponseSeek;                                           // 跳转响应
- (void)upnpResponsePrevious;                                       // 以前的响应
- (void)upnpResponseNext;                                           // 下一个响应
- (void)upnpResponseSetVolume;                                      // 设置音量响应
- (void)upnpResponseSetNextAVTransportURI;                          // 设置下一个url响应
- (void)upnpResponseGetVolume:(NSString *)volume;                   // 获取音频信息
- (void)upnpResponseGetPositionInfo:(CCUPnPPositionInfo *)info;     // 获取播放进度

@end

@interface CCUPnPRender : NSObject

@property (nonatomic, strong) id <CCUPnPRenderResponseDelegate> delegate;

- (instancetype)initWithModel:(CCUPnPDevice *)model;
// 设置投屏地址
- (void)setAVTransportURL:(NSString *)urlStr;
// 设置下一个播放地址
- (void)setNextAVTransportURI:(NSString *)urlStr;
// 播放
- (void)play;
// 暂停
- (void)pause;
// 结束
- (void)stop;
// 下一个
- (void)next;
// 前一个
- (void)previous;
// 跳转进度
- (void)seek:(float)relTime;
// 跳转至特定进度或视频
- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit;
// 获取播放进度,可通过协议回调使用
- (void)getPositionInfo;
// 获取播放状态,可通过协议回调使用
- (void)getTransportInfo;
// 获取音量
- (void)getVolume;
// 设置音量
- (void)setVolumeWith:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
