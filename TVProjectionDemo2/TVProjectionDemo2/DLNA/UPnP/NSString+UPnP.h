//
//  NSString+UPnP.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UPnP)

+ (NSString *)upnp_stringWithDurationTime:(CGFloat)timeValue;
- (CGFloat)upnp_durationTime;

@end

NS_ASSUME_NONNULL_END
