//
//  CCUPnPRender.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPRender.h"
#import "CCUPnPDefine.h"
#import "GDataXMLNode.h"
#import "CCUPnPAction.h"
#import "NSString+UPnP.h"
#import "CCUPnPPositionInfo.h"
#import "CCUPnPTransportInfo.h"

static NSString *kVideoDIDL =
@"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" \
             xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:sec=\"http://www.sec.co.kr/\" \
             xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\">\
             <item id=\"f-0\"parentID=\"0\" restricted=\"0\">\
                <dc:title>Video</dc:title>\
                <dc:creator>Anonymous</dc:creator>\
                <upnp:class>object.item.videoItem</upnp:class>\
                <res protocolInfo=\"http-get:*:video/*:DLNA.ORG_OP=01;\
                     DLNA.ORG_CI=0;DLNA.ORG_FLAGS=01700000000000000000000000000000\" sec:URIType=\"public\">%@</res>\
             </item>\
  </DIDL-Lite>";

@interface CCUPnPRender ()

@property (nonatomic, strong) CCUPnPDevice *model;

@end

@implementation CCUPnPRender

- (instancetype)initWithModel:(CCUPnPDevice *)model
{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

#pragma mark -- AVTransport动作 --
- (void)setAVTransportURL:(NSString *)urlStr
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:urlStr forName:@"CurrentURI"];
    [action setArgumentValue:kVideoDIDL forName:@"CurrentURIMetaData"];
    [self postRequestWith:action];
}

- (void)setNextAVTransportURI:(NSString *)urlStr
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"SetNextAVTransportURI"];
    [action setArgumentValue:urlStr forName:@"NextURI"];
    [action setArgumentValue:@"" forName:@"NextURIMetaData"];
    [self postRequestWith:action];
    
}

- (void)play
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Play"];
    [action setArgumentValue:@"1" forName:@"Speed"];
    [self postRequestWith:action];
}

- (void)pause
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Pause"];
    [self postRequestWith:action];
}

- (void)stop
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Stop"];
    [self postRequestWith:action];
}

- (void)next
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Next"];
    [self postRequestWith:action];
}

- (void)previous
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Previous"];
    [self postRequestWith:action];
}

- (void)getPositionInfo
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"GetPositionInfo"];
    [self postRequestWith:action];
}

- (void)getTransportInfo
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"GetTransportInfo"];
    [self postRequestWith:action];
}

- (void)seek:(float)relTime
{
    [self seekToTarget:[NSString upnp_stringWithDurationTime:relTime] Unit:unitREL_TIME];
}

- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"Seek"];
    [action setArgumentValue:unit forName:@"Unit"];
    [action setArgumentValue:target forName:@"Target"];
    [self postRequestWith:action];
}

#pragma mark -- RenderingControl动作 --
- (void)getVolume
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"GetVolume"];
    [action setServiceType:CCUPnPServiceTypeRenderingControl];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [self postRequestWith:action];
}

- (void)setVolumeWith:(NSString *)value
{
    CCUPnPAction *action = [[CCUPnPAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:CCUPnPServiceTypeRenderingControl];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:value forName:@"DesiredVolume"];
    [self postRequestWith:action];
}

#pragma mark - 发送动作请求
- (void)postRequestWith:(CCUPnPAction *)action
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[action getPostUrlStrWith:_model]];
    NSString *postXML = [action getPostXMLFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action getSOAPAction] forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [postXML dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData * _Nullable data,
                                        NSURLResponse * _Nullable response,
                                        NSError * _Nullable error) {
        if (error || data == nil) {
            [self _UndefinedResponse:nil postXML:postXML];
            return;
        } else {
            [self parseRequestResponseData:data postXML:postXML];
        }
    }];
    [dataTask resume];
}

#pragma mark - 动作响应
- (void)parseRequestResponseData:(NSData *)data postXML:(NSString *)postXML
{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self resultsWith:needArr postXML:postXML];
        } else {
            [self _UndefinedResponse:[xmlEle XMLString] postXML:postXML];
        }
    }
}

- (void)resultsWith:(NSArray *)array postXML:(NSString *)postXML
{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
//        LOG_DLNA(@"response-action:%@", ele.name);
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
            [self _SetAVTransportURIResponse];
            // 有些设备传递播放URI后就能直接播放，有些设备设置URI后需要发送播放命令，
            // 可以在接收到 SetAVTransportURIResponse 响应后调用播放动作来解决
//            [self getTransportInfo];
        } else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]) {
            [self _SetNextAVTransportURIResponse];
        } else if ([[ele name] hasSuffix:@"PauseResponse"]) {
            [self _PauseResponse];
        } else if ([[ele name] hasSuffix:@"PlayResponse"]) {
            [self _PlayResponse];
        } else if ([[ele name] hasSuffix:@"StopResponse"]) {
            [self _StopResponse];
        } else if ([[ele name] hasSuffix:@"SeekResponse"]) {
            [self _SeekResponse];
        } else if ([[ele name] hasSuffix:@"NextResponse"]) {
            [self _NextResponse];
        } else if ([[ele name] hasSuffix:@"PreviousResponse"]) {
            [self _PreviousResponse];
        } else if ([[ele name] hasSuffix:@"SetVolumeResponse"]) {
            [self _SetVolumeResponse];
        } else if ([[ele name] hasSuffix:@"GetVolumeResponse"]) {
            [self _GetVolumeSuccessWith:[ele children]];
        } else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]) {
            [self _GetPositionInfoResponseWith:[ele children]];
        } else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]) {
            [self _GetTransportInfoResponseWith:[ele children]];
        } else {
            [self _UndefinedResponse:[ele XMLString] postXML:postXML];
        }
    }
}

#pragma mark - 回调协议
- (void)_SetAVTransportURIResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseSetAVTransportURI)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseSetAVTransportURI];
        });
    }
}

- (void)_SetNextAVTransportURIResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseSetNextAVTransportURI)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseSetNextAVTransportURI];
        });
    }
}

- (void)_PauseResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponsePause)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponsePause];
        });
    }
}

- (void)_PlayResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponsePlay)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponsePlay];
        });
    }
}

- (void)_StopResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseStop)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseStop];
        });
    }
}

- (void)_SeekResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseSeek)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseSeek];
        });
    }
}

- (void)_NextResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseNext)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseNext];
        });
    }
}

- (void)_PreviousResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponsePrevious)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponsePrevious];
        });
    }
}

- (void)_SetVolumeResponse
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseSetVolume)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseSetVolume];
        });
    }
}

- (void)_GetVolumeSuccessWith:(NSArray *)array
{
    for (int j = 0; j < array.count; j++) {
        GDataXMLElement *eleXml = [array objectAtIndex:j];
        if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(upnpResponseGetVolume:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate upnpResponseGetVolume:[eleXml stringValue]];
                });
            }
        }
    }
}

- (void)_GetPositionInfoResponseWith:(NSArray *)array
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseGetPositionInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CCUPnPPositionInfo *info = [[CCUPnPPositionInfo alloc] init];
            [info setArray:array];
            [self.delegate upnpResponseGetPositionInfo:info];
        });
    }
}

- (void)_GetTransportInfoResponseWith:(NSArray *)array
{
    if ([self.delegate respondsToSelector:@selector(upnpResponseGetTransportInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CCUPnPTransportInfo *info = [[CCUPnPTransportInfo alloc] init];
            [info setArray:array];
            [self.delegate upnpResponseGetTransportInfo:info];
        });
    }
}

- (void)_UndefinedResponse:(NSString *)xmlStr postXML:(NSString *)postXML
{
//    LOG_DLNA(@"UndefinedResponse: responseXmlStr:%@, postXML:%@", xmlStr, postXML);
    if ([self.delegate respondsToSelector:@selector(upnpResponseUndefined:postXML:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate upnpResponseUndefined:xmlStr postXML:postXML];
        });
    }
}

@end
