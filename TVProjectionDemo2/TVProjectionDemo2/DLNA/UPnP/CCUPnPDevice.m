//
//  CCUPnPDevice.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPDevice.h"
#import "CCUPnPDefine.h"
#import "GDataXMLNode.h"
#import "CCUPnPServiceInfo.h"

@implementation CCUPnPDevice

- (CCUPnPServiceInfo *)AVTransport
{
    if (!_AVTransport) {
        _AVTransport = [[CCUPnPServiceInfo alloc] init];
    }
    return _AVTransport;
}

- (CCUPnPServiceInfo *)RenderingControl
{
    if (!_RenderingControl) {
        _RenderingControl = [[CCUPnPServiceInfo alloc] init];
    }
    return _RenderingControl;
}

- (NSString *)URLHeader
{
    if (!_URLHeader) {
        _URLHeader = [NSString stringWithFormat:@"%@://%@:%@",
                      [self.loaction scheme], [self.loaction host], [self.loaction port]];
    }
    return _URLHeader;
}

- (void)setArray:(NSArray *)array
{
    @autoreleasepool {
        for (int j = 0; j < [array count]; j++) {
            GDataXMLElement *ele = [array objectAtIndex:j];
            if ([ele.name isEqualToString:@"friendlyName"]) {
                self.friendlyName = [ele stringValue];
            }
            if ([ele.name isEqualToString:@"modelName"]) {
                self.modelName = [ele stringValue];
            }
            if ([ele.name isEqualToString:@"serviceList"]) {
                NSArray *serviceListArray = [ele children];
                for (int k = 0; k < [serviceListArray count]; k++) {
                    GDataXMLElement *listEle = [serviceListArray objectAtIndex:k];
                    if ([listEle.name isEqualToString:@"service"]) {
                        NSString *serviceString = [listEle stringValue];
                        if ([serviceString rangeOfString:serviceType_AVTransport].location != NSNotFound ||
                            [serviceString rangeOfString:serviceId_AVTransport].location != NSNotFound) {
                            [self.AVTransport setArray:[listEle children]];
                        } else if ([serviceString rangeOfString:serviceType_RenderingControl].location != NSNotFound ||
                                   [serviceString rangeOfString:serviceId_RenderingControl].location != NSNotFound) {
                            [self.RenderingControl setArray:[listEle children]];
                        }
                    }
                }
                continue;
            }
        }
    }
}

- (NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"\nuuid:%@\nlocation:%@\nURLHeader:%@\n\
                                     friendlyName:%@\nmodelName:%@\n",
                        self.uuid,self.loaction,self.URLHeader,self.friendlyName,self.modelName];
    return string;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    CCUPnPDevice *device = [[CCUPnPDevice alloc] init];
    device.uuid = [device.uuid copy];
    device.loaction = [device.loaction copy];
    device.URLHeader = [device.URLHeader copy];
    device.friendlyName = [device.friendlyName copy];
    device.modelName = [device.modelName copy];
    device.AVTransport = [device.AVTransport copy];
    device.RenderingControl = [device.RenderingControl copy];
    return device;
}

@end
