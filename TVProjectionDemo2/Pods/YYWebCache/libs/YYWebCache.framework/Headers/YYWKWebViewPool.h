//
//  YYWKWebViewPool.h
//  libBaseService
//
//  Created by luph on 2019/7/23.
//  Copyright © 2019 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@class WKWebView,YYWKWebViewPool;

@protocol YYWKWebViewPoolDelegate <NSObject>
- (WKWebView *)generatWebViewWithPool:(YYWKWebViewPool *)pool; //生成webview（默认返回WKWebView）
- (void)webViewPool:(YYWKWebViewPool *)pool prepareForReuse:(WKWebView *)webView;//复用前的准备工作
- (void)webViewPool:(YYWKWebViewPool *)pool prepareForRecycle:(WKWebView *)webView;//回收时的重置操作
@end

@interface YYWKWebViewPool : NSObject

//有时回收是在dealloc中调用，这时self.delegate已经为nil，因此这里使用unsafe_unretained
@property (nonatomic, unsafe_unretained) id<YYWKWebViewPoolDelegate> delegate;

//初始化复用池（启动时调用）
+ (void)initializePool:(WKWebView *(^)(void))generatBlock;

//实例复用池
+ (YYWKWebViewPool *)instancePoolWithDelegate:(id<YYWKWebViewPoolDelegate>) delegate;

//从复用池取出指定classKind类型的webview
//若无可用将新建一个实例返回
- (WKWebView *)getReusedWebViewWithClass:(Class)classKind;

//从复用池取出WKWebView类型的webview
- (WKWebView *)getReusedWebView;

//回收webView
- (void)recycleReusedWebView:(WKWebView *)webView;

@end
