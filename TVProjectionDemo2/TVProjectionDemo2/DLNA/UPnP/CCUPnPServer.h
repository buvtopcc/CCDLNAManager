//
//  CCUPnPServer.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCUPnPDevice;

@protocol CCUPnPServerDelegate <NSObject>

- (void)upnpServerSearchChangeWithResults:(NSArray <CCUPnPDevice *> *)devices;
- (void)upnpServerSearchErrorWithError:(NSError *)error;
- (void)upnpServerSearchOutTime;

@end

@interface CCUPnPServer : NSObject

@property (nonatomic, weak) id <CCUPnPServerDelegate> delegate;
// 搜索超时时间
@property (nonatomic, assign) NSInteger searchOutTime;

+ (instancetype)shareServer;
- (void)start;
- (void)stop;
- (void)search;
- (NSArray <CCUPnPDevice *> *)getDeviceList;

@end

NS_ASSUME_NONNULL_END
