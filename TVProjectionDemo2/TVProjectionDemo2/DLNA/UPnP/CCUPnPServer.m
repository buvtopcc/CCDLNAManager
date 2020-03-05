//
//  CCUPnPServer.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPDefine.h"
#import "CCUPnPServer.h"
#import "GCDAsyncUdpSocket.h"
#import "GDataXMLNode.h"
#import "CCUPnPDevice.h"

@interface CCUPnPServer ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
// key: usn(uuid) string,  value: device
@property (nonatomic, strong) NSMutableDictionary<NSString *, CCUPnPDevice *> *deviceDictionary;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL receiveDevice;

@end

@implementation CCUPnPServer

+ (instancetype)shareServer
{
    static CCUPnPServer *server;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[self alloc] init];
    });
    return server;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.receiveDevice = YES;
        _queue = dispatch_queue_create("com.hustcc.upnp.dlna", DISPATCH_QUEUE_SERIAL);
        _deviceDictionary = [NSMutableDictionary dictionary];
        _udpSocket = [[GCDAsyncUdpSocket alloc]
                      initWithDelegate:self
                      delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (NSString *)getSearchString
{
    NSMutableString *searchMutableString = [NSMutableString string];
    [searchMutableString appendString:@"M-SEARCH * HTTP/1.1\r\n"];
    [searchMutableString appendFormat:@"HOST: %@:%d\r\n", ssdpAddres, ssdpPort];
    [searchMutableString appendString:@"MAN: \"ssdp:discover\"\r\n"];
    [searchMutableString appendString:@"MX: 3\r\n"];
    [searchMutableString appendFormat:@"ST: %@\r\n", serviceType_AVTransport];
    [searchMutableString appendString:@"USER-AGENT: hustcc-iOS UPnP/1.1 dlna/1.0\r\n\r\n"];
    return searchMutableString;
}

- (void)start
{
    NSError *error = nil;
    if (![_udpSocket bindToPort:ssdpPort error:&error]) {
        [self onError:error];
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        [self onError:error];
    }
    
    if (![_udpSocket joinMulticastGroup:ssdpAddres error:&error]) {
        [self onError:error];
    }
    [self search];
}

- (void)stop
{
    [_udpSocket close];
    // 取消超时回调
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)search
{
    // 搜索前先清空设备列表
    [self.deviceDictionary removeAllObjects];
    self.receiveDevice = YES;
//    [self onChange];
    NSData *sendData = [[self getSearchString] dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:sendData toHost:ssdpAddres port:ssdpPort withTimeout:-1 tag:1];
}

- (NSArray<CCUPnPDevice *> *)getDeviceList
{
    return self.deviceDictionary.allValues;
}


#pragma mark -- GCDAsyncUdpSocketDelegate --
- (void)performOutTimeActions
{
    if ([self.delegate respondsToSelector:@selector(upnpServerSearchOutTime)]) {
        [self.delegate upnpServerSearchOutTime];
    }
    self.receiveDevice = NO;
    NSLog(@"搜索结束");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
    dispatch_async(dispatch_get_main_queue(), ^{
      [self performSelector:@selector(performOutTimeActions) withObject:nil afterDelay:self.searchOutTime];
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self onError:error];
    });
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError * _Nullable)error
{
    NSLog(@"udpSocket关闭");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext
{
    [self JudgeDeviceWithData:data];
}

// 判断设备
- (void)JudgeDeviceWithData:(NSData *)data
{
    @autoreleasepool {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([string hasPrefix:@"NOTIFY"]) {
            NSString *serviceType = [self headerValueForKey:@"NT:" inData:string];
            if ([serviceType isEqualToString:serviceType_AVTransport]) {
                NSString *location = [self headerValueForKey:@"Location:" inData:string];
                NSString *usn = [self headerValueForKey:@"USN:" inData:string];
                NSString *ssdp = [self headerValueForKey:@"NTS:" inData:string];
                if ([self isNilString:ssdp]) {
                    NSLog(@"ssdp = nil");
                    return;
                }
                if ([self isNilString:usn]) {
                    NSLog(@"usn = nil");
                    return;
                }
                if ([self isNilString:location]) {
                    NSLog(@"location = nil");
                    return;
                }
                if ([ssdp isEqualToString:@"ssdp:alive"]) {
                    dispatch_async(_queue, ^{
                        if ([self.deviceDictionary objectForKey:usn] == nil) {
                            [self addDevice:[self getDeviceWithLocation:location withUSN:usn] forUSN:usn];
                        }
                    });
                }
                else if ([ssdp isEqualToString:@"ssdp:byebye"]) {
                    dispatch_async(_queue, ^{
                        [self removeDeviceWithUSN:usn];
                    });
                }
            }
        } else if ([string hasPrefix:@"HTTP/1.1"]) {
            NSString *location = [self headerValueForKey:@"Location:" inData:string];
            NSString *usn = [self headerValueForKey:@"USN:" inData:string];
            if ([self isNilString:usn]) {
                NSLog(@"usn = nil");
                return;
            }
            if ([self isNilString:location]) {
                NSLog(@"location = nil");
                return;
            }
            dispatch_async(_queue, ^{
                if ([self.deviceDictionary objectForKey:usn] == nil) {
                    [self addDevice:[self getDeviceWithLocation:location withUSN:usn] forUSN:usn];
                }
            });
        }
    }
}

- (void)addDevice:(CCUPnPDevice *)device forUSN:(NSString *)usn
{
    if (!device) {
        return;
    }
//    NSLog(@"%@",device.description);
    [self.deviceDictionary setObject:device forKey:usn];
    [self onChange];
}

- (void)removeDeviceWithUSN:(NSString *)usn
{
    [self.deviceDictionary removeObjectForKey:usn];
    [self onChange];
}

- (void)onChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.receiveDevice && self.delegate && [self.delegate respondsToSelector:
                                                    @selector(upnpServerSearchChangeWithResults:)]) {
            [self.delegate upnpServerSearchChangeWithResults:self.deviceDictionary.allValues];
        }
    });
}

- (void)onError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(upnpServerSearchErrorWithError:)]) {
        [self.delegate upnpServerSearchErrorWithError:error];
    }
}

#pragma mark -- private method --
- (NSString *)headerValueForKey:(NSString *)key inData:(NSString *)data
{
    NSString *str = [NSString stringWithFormat:@"%@", data];
    
    NSRange keyRange = [str rangeOfString:key options:NSCaseInsensitiveSearch];
    
    if (keyRange.location == NSNotFound) {
        return @"";
    }
    
    str = [str substringFromIndex:keyRange.location + keyRange.length];
    
    NSRange enterRange = [str rangeOfString:@"\r\n"];
    if (enterRange.location == NSNotFound) {
        return @"";
    }
    NSString *value = [[str substringToIndex:enterRange.location]
                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return value;
}

- (CCUPnPDevice *)getDeviceWithLocation:(NSString *)location withUSN:(NSString *)usn
{
    // 阻塞操作，需要放到非主线程中处理
    dispatch_semaphore_t seamphore = dispatch_semaphore_create(0);
    
    __block CCUPnPDevice *device = nil;
    NSURL *URL = [NSURL URLWithString:location]; // 超时时间先设5.0s
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    request.HTTPMethod = @"GET";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self onError:error];
        } else {
            if (response != nil && data != nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if ([httpResponse statusCode] == 200) {
                    device = [[CCUPnPDevice alloc] init];
                    device.loaction = URL;
                    device.uuid = usn;
                    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
                    GDataXMLElement *xmlEle = [xmlDoc rootElement];
                    NSArray *xmlArray = [xmlEle children];
                    for (int i = 0; i < [xmlArray count]; i++) {
                        GDataXMLElement *element = [xmlArray objectAtIndex:i];
                        if ([[element name] isEqualToString:@"device"]) {
                            [device setArray:[element children]];
                            continue;
                        }
                    }
                }
            }
        }
        dispatch_semaphore_signal(seamphore);
    }] resume];
    dispatch_semaphore_wait(seamphore, DISPATCH_TIME_FOREVER);
    return device;
}

- (BOOL)isNilString:(NSString *)_str
{
    if (_str == nil || _str == NULL || [_str isEqual:@"null"] || [_str isEqual:[NSNull null]]
        || [_str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![_str isKindOfClass:[NSString class]]) {
        return YES;
    }
    _str = [NSString stringWithFormat:@"%@", _str];
    if ([_str isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([_str isEqualToString:@""]) {
        return YES;
    }
    if ([_str isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

@end
