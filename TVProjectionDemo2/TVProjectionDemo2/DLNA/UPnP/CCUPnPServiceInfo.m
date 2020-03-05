//
//  CCUPnPServiceInfo.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPServiceInfo.h"
#import "GDataXMLNode.h"

@implementation CCUPnPServiceInfo

- (void)setArray:(NSArray *)array
{
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"serviceType"]) {
                self.serviceType = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"serviceId"]) {
                self.serviceId = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"controlURL"]) {
                self.controlURL = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"eventSubURL"]) {
                self.eventSubURL = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"SCPDURL"]) {
                self.scpdURL = [needEle stringValue];
            }
        }
    }
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    CCUPnPServiceInfo *info = [[CCUPnPServiceInfo alloc] init];
    info.serviceType = [self.serviceType copy];
    info.serviceId = [self.serviceId copy];
    info.controlURL = [self.controlURL copy];
    info.eventSubURL = [self.eventSubURL copy];
    info.scpdURL = [self.scpdURL copy];
    return info;
}



@end
