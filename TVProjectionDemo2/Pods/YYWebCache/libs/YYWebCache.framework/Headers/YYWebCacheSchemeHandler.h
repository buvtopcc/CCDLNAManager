//
//  WKURLCustomSchemeHandler.h
//  libBaseService
//
//  Created by luph on 2019/5/21.
//  Copyright © 2019 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKURLSchemeHandler.h>


NS_ASSUME_NONNULL_BEGIN
typedef void (^YYWebCacheImageFinishCallback)(UIImage * _Nullable image, NSError * _Nullable error);
typedef void (^YYWebCacheImageDataBlock)(NSURL *url, YYWebCacheImageFinishCallback finishBlock);

@interface YYWebCacheSchemeHandler : NSObject<WKURLSchemeHandler>

//创建实例， originUrlScheme为 还原url请求时的协议名
//imageDataBlock 可选，图片请求拦截，业务侧可使用自有图片库进行接入
+ (YYWebCacheSchemeHandler *)handlerWithOriginUrlScheme:(NSString *)originUrlScheme imageDataBlock:(YYWebCacheImageDataBlock)imageDataBlock;


//（debug feature）是否显示命中缓存的toast提示，只显示一次（若webview被复用则不再二次显示）
@property (nonatomic, assign) BOOL showCacheTip;

@end

NS_ASSUME_NONNULL_END
