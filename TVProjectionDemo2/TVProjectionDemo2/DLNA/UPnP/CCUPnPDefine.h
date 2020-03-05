//
//  CCUPnPDefine.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#ifndef CCUPnPDefine_h
#define CCUPnPDefine_h

#import <Foundation/Foundation.h>
#import "CCUPnPServer.h"
#import "CCUPnPDevice.h"
#import "CCUPnPRender.h"
#import "CCUPnPPositionInfo.h"
#import "CCUPnPTransportInfo.h"
#import "NSString+UPnP.h"

//IPv4下的多播地址
static NSString *ssdpAddres = @"239.255.255.250";
//IPv4下的SSDP端口
static UInt16   ssdpPort = 1900;

static NSString *serviceType_AVTransport        = @"urn:schemas-upnp-org:service:AVTransport:1";

static NSString *serviceType_RenderingControl   = @"urn:schemas-upnp-org:service:RenderingControl:1";

static NSString *serviceId_AVTransport          = @"urn:upnp-org:serviceId:AVTransport";
static NSString *serviceId_RenderingControl     = @"urn:upnp-org:serviceId:RenderingControl";


static NSString *unitREL_TIME = @"REL_TIME";
static NSString *unitTRACK_NR = @"TRACK_NR";

#endif /* CCUPnPDefine_h */
