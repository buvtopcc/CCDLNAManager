//
//  CCUPnPAction.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/7.
//  Copyright © 2019 buvtopcc. All rights reserved.
//

#import "CCUPnPAction.h"
#import "GDataXMLNode.h"
#import "CCUPnPDefine.h"
#import "CCUPnPServiceInfo.h"
#import "CCUPnPDevice.h"

@interface CCUPnPAction ()

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) GDataXMLElement *XMLElement;

@end

@implementation CCUPnPAction

- (instancetype)initWithAction:(NSString *)action
{
    self = [super init];
    if (self) {
        _action = action;
        _serviceType = CCUPnPServiceTypeAVTransport;
        NSString *name = [NSString stringWithFormat:@"u:%@", _action];
        self.XMLElement = [GDataXMLElement elementWithName:name];
        [self setArgumentValue:@"0" forName:@"InstanceID"]; // s:body默认参数
    }
    return self;
}

- (void)setServiceType:(CCUPnPServiceType)serviceType
{
    _serviceType = serviceType;
}

- (void)setArgumentValue:(NSString *)value forName:(NSString *)name
{
    [self.XMLElement addChild:[GDataXMLElement elementWithName:name stringValue:value]];
}

- (NSString *)getServiceType
{
    if (_serviceType == CCUPnPServiceTypeAVTransport) {
        return serviceType_AVTransport;
    } else {
        return serviceType_RenderingControl;
    }
}

- (NSString *)getSOAPAction
{
    if (_serviceType == CCUPnPServiceTypeAVTransport) {
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceType_AVTransport, _action];
    } else {
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceType_RenderingControl, _action];
    }
}

- (NSString *)getPostUrlStrWith:(CCUPnPDevice *)model
{
    if (_serviceType == CCUPnPServiceTypeAVTransport) {
        return [self getUPnPURLWithUrlModel:model.AVTransport urlHeader:model.URLHeader];
    } else {
        return [self getUPnPURLWithUrlModel:model.RenderingControl urlHeader:model.URLHeader];;
    }
}

- (NSString *)getUPnPURLWithUrlModel:(CCUPnPServiceInfo *)model urlHeader:(NSString *)urlHeader
{
    if ([[model.controlURL substringToIndex:1] isEqualToString:@"/"]) {
        return [NSString stringWithFormat:@"%@%@", urlHeader, model.controlURL];
    } else {
        return [NSString stringWithFormat:@"%@/%@", urlHeader, model.controlURL];
    }
}

/*
 <DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
 xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\" xmlns:dlna=\"urn:schemas-dlna-org:metadata-1-0/\">
 <item id=\"0$1$1$17956\" parentID=\"parent\" restricted=\"1\"><dc:title>%s</dc:title>
 <upnp:class>object.item.videoItem</upnp:class>
 <res protocolInfo=\"http-get:*:application/vnd.apple.mpegurl:*\">%s</res></item></DIDL-Lite>
 */

- (NSString *)getPostXMLFile
{
    GDataXMLElement *xmlEle = [GDataXMLElement elementWithName:@"s:Envelope"];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"s:encodingStyle"
                                            stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:s"
                                            stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:u"
                                            stringValue:[self getServiceType]]];
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [command addChild:self.XMLElement];
    [xmlEle addChild:command];
    return xmlEle.XMLString;
}

@end
