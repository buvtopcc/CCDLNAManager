//
//  CCUPnPDevice.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCUPnPServiceInfo;

@interface CCUPnPDevice : NSObject <NSCopying>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSURL *loaction;
@property (nonatomic, copy) NSString *URLHeader;

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;

@property (nonatomic, strong) CCUPnPServiceInfo *AVTransport;
@property (nonatomic, strong) CCUPnPServiceInfo *RenderingControl;

- (void)setArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
