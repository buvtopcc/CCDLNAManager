//
//  YYWebCacheHandler.h
//  libBaseService
//
//  Created by luph on 2019/7/22.
//  Copyright © 2019 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYWebCacheSchemeHandler.h"
@class WKWebViewConfiguration;

@interface YYWebCacheManager : NSObject

//启动webcache配置（启动时调用，并下载配置缓存）
//hookScheme ：拦截时使用的自定义协议名
//isTestServer：服务器环境
//logOutputBlock：日志输出
+ (void)launchWithAppName:(NSString *)appName hookScheme:(NSString *)urlScheme isTestServer:(BOOL)isTestServer;
+ (void)launchWithAppName:(NSString *)appName hookScheme:(NSString *)urlScheme isTestServer:(BOOL)isTestServer logOutputBlock:(void(^)(NSString *logStr))block;
+ (void)launchWithAppName:(NSString *)appName hookScheme:(NSString *)urlScheme isTestServer:(BOOL)isTestServer logOutputBlock:(void(^)(NSString *logStr))block imageDataBlock:(YYWebCacheImageDataBlock)imageDataBlock;

//拉取缓存配置，（若有更新则）下载缓存文件
+ (void)requestConfig;

//绑定拦截器
/*
 configuration : 初始化webview时的配置
 showCacheTip : （debug feature）是否显示命中缓存的toast提示，只显示一次（若webview被复用则不再二次显示）
 originUrlScheme : 还原url请求时的协议名
 */
+ (void)bindSchemeHandler:(WKWebViewConfiguration *)configuration showCacheTip:(BOOL)showCacheTip originUrlScheme:(NSString *)originUrlScheme;

//返回request的缓存文件路径，无对应缓存返回nil
+ (NSString *)getCacheResWithRequest:(NSURLRequest *)request;

//请求资源类型
+ (NSString *)getAcceptWith:(NSURLRequest *)request;

//清除缓存
+ (void)clearAllWebCache;

//若urlStr命中配置项目，则返回协议名为urlScheme的url，使之能够被拦截
+ (NSString *)converUrlWebCacheSchemeIfNeed:(NSString *)urlStr;

//是否命中域名白名单（只有命中白名单的url请求才能够使用缓存）
+ (BOOL)isHitWhiteList:(NSString *)urlStr;

//获取初始化时设置的自定义协议名
+ (NSString *)getUrlScheme;
@end

