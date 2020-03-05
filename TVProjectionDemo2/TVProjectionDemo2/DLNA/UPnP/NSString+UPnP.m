//
//  NSString+UPnP.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation NSString (UPnP)

+ (NSString *)upnp_stringWithDurationTime:(CGFloat)timeValue
{
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            (int)(timeValue / 3600.0),
            (int)(fmod(timeValue, 3600.0) / 60.0),
            (int)fmod(timeValue, 60.0)];
}

- (CGFloat)upnp_durationTime
{
    NSArray *timeStrings = [self componentsSeparatedByString:@":"];
    int timeStringsCount = (int)[timeStrings count];
    if (timeStringsCount < 3) {
        return -1.0f;
    }
    CGFloat durationTime = 0.0;
    for (int n = 0; n < timeStringsCount; n++) {
        NSString *timeString = [timeStrings objectAtIndex:n];
        int timeIntValue = [timeString intValue];
        switch (n) {
            case 0: // HH
                durationTime += timeIntValue * (60 * 60);
                break;
            case 1: // MM
                durationTime += timeIntValue * 60;
                break;
            case 2: // SS
                durationTime += timeIntValue;
                break;
            case 3: // .F?
                durationTime += timeIntValue * 0.1;
                break;
            default:
                break;
        }
    }
    return durationTime;
}

@end
