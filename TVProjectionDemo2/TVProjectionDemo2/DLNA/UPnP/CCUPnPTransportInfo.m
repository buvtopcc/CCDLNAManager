//
//  CCUPnPTransportInfo.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPTransportInfo.h"
#import "GDataXMLNode.h"

@implementation CCUPnPTransportInfo

- (void)setArray:(NSArray *)array
{
    @autoreleasepool {
        for (int m = 0; m < array.count; m++) {
            GDataXMLElement *needEle = [array objectAtIndex:m];
            if ([needEle.name isEqualToString:@"CurrentTransportState"]) {
                self.currentTransportState = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"CurrentTransportStatus"]) {
                self.currentTransportStatus = [needEle stringValue];
            }
            if ([needEle.name isEqualToString:@"CurrentSpeed"]) {
                self.currentSpeed = [needEle stringValue];
            }
        }
    }
}

@end
