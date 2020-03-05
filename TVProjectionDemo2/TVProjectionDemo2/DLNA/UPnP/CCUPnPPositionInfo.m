//
//  CCUPnPPositionInfo.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPPositionInfo.h"
#import "GDataXMLNode.h"
#import "NSString+UPnP.h"

@implementation CCUPnPPositionInfo

- (void)setArray:(NSArray *)array
{
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"TrackDuration"]) {
                self.trackDuration = [[needEle stringValue] upnp_durationTime];
            }
            if ([needEle.name isEqualToString:@"RelTime"]) {
                self.relTime = [[needEle stringValue] upnp_durationTime];
            }
            if ([needEle.name isEqualToString:@"AbsTime"]) {
                self.absTime = [[needEle stringValue] upnp_durationTime];
            }
        }
    }
}

@end
