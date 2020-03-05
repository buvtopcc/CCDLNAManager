//
//  CCUPnPServiceInfo.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCUPnPServiceInfo : NSObject <NSCopying>

@property (nonatomic, copy) NSString *serviceType;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *controlURL;
@property (nonatomic, copy) NSString *eventSubURL;
@property (nonatomic, copy) NSString *scpdURL; // service control protocol description URL

- (void)setArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
