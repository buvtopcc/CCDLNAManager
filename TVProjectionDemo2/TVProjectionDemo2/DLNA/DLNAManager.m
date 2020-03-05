//
//  DLNAManager.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "DLNAManager.h"
#import "CCUPnPDefine.h"
#import "CCUPnPServer.h"
#import "CCUPnPRender.h"
#import "CCUPnPDevice.h"
#import "CCUPnPTransportInfo.h"

@interface DLNAManager()<CCUPnPServerDelegate, CCUPnPRenderResponseDelegate>

@property(nonatomic, strong) CCUPnPServer *upd;              // MDS服务器
@property(nonatomic, strong) NSMutableArray *deviceArray;
@property(nonatomic, strong) CCUPnPRender *render;           // MDR渲染器
@property(nonatomic, copy) NSString *volume;
@property(nonatomic, assign) NSInteger seekTime;
@property(nonatomic, assign) BOOL isPlaying;

@end

@implementation DLNAManager

+ (instancetype)sharedDLNAManager
{
    static DLNAManager *dlnaManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dlnaManager = [[DLNAManager alloc] init];
    });
    return dlnaManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CCUPnPServer shareServer];
        self.upd.searchOutTime = 5;
        self.upd.delegate = self;
        self.deviceArray = [NSMutableArray array];
    }
    return self;
}

- (void)startDLNAPlay
{
    [self initCLUPnPRendererAndDlnaPlay];
}

- (void)startDLNAPlayAfterStopPreviouslyForce
{
//    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
//        [self initCLUPnPRendererAndDlnaPlay];
//
//    } failure:^{
//        [self initCLUPnPRendererAndDlnaPlay];
//    }];
//    [action executeAction];
}
- (void)initCLUPnPRendererAndDlnaPlay
{
    self.render = [[CCUPnPRender alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
}

- (void)endDLNAPlay
{
    [self.render stop];
}

- (void)dlnaPlay
{
    [self.render play];
}

- (void)dlnaPause
{
    [self.render pause];
}

- (void)startSearch
{
    [self.upd start];
}

- (void)stopSearch
{
    [self.upd stop];
}

- (void)volumeChanged:(NSString *)volume
{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}

- (void)seekChanged:(NSInteger)seek
{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

- (void)playTheURL:(NSString *)url
{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpServerSearchChangeWithResults:(NSArray<CCUPnPDevice *> *)devices
{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    NSLog(@"%@",devices);
    for (CCUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(dlnaManagerDeviceSearchResult:)]) {
        [self.delegate dlnaManagerDeviceSearchResult:[deviceMarr copy]];
    }
    self.deviceArray = deviceMarr;
}

- (void)upnpServerSearchErrorWithError:(NSError *)error
{
//    LOG_DLNA(@"DLNA SearchError:%@", error);
}

- (void)upnpServerSearchOutTime
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dlnaManagerSearchOutTime)]) {
        [self.delegate dlnaManagerSearchOutTime];
    }
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpResponseSetAVTransportURI
{
    [self.render play];
}

- (void)upnpResponseGetTransportInfo:(CCUPnPTransportInfo *)info
{
//    LOG_DLNA(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] ||
          [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

- (void)upnpResponsePlay
{
    if ([self.delegate respondsToSelector:@selector(dlnaManagerResponseStartPlay)]) {
        [self.delegate dlnaManagerResponseStartPlay];
    }
}

- (void)upnpResponsePause
{
    if ([self.delegate respondsToSelector:@selector(dlnaManagerResponsePause)]) {
        [self.delegate dlnaManagerResponsePause];
    }
}

- (void)upnpResponseNext
{
    if ([self.delegate respondsToSelector:@selector(dlnaManagerResponseNext)]) {
        [self.delegate dlnaManagerResponseNext];
    }
}

#pragma mark Set&Get
- (void)setSearchOutTime:(NSInteger)searchOutTime
{
    _searchOutTime = searchOutTime;
    self.upd.searchOutTime = searchOutTime;
}

@end
