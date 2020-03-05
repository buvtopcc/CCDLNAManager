//
//  CCUPnPAction.h
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CCUPnPServiceType) {
    CCUPnPServiceTypeAVTransport,       // @"urn:schemas-upnp-org:service:AVTransport:1"
    CCUPnPServiceTypeRenderingControl   // @"urn:schemas-upnp-org:service:RenderingControl:1"
};

@class CCUPnPDevice;

@interface CCUPnPAction : NSObject

// serviceType 默认 CCUPnPServiceTypeAVTransport
@property (nonatomic, assign) CCUPnPServiceType serviceType;

- (instancetype)initWithAction:(NSString *)action;
- (void)setArgumentValue:(NSString *)value forName:(NSString *)name;
- (NSString *)getServiceType;
- (NSString *)getSOAPAction;
- (NSString *)getPostUrlStrWith:(CCUPnPDevice *)model;
- (NSString *)getPostXMLFile;

@end

NS_ASSUME_NONNULL_END
