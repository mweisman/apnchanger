//
//  APNCarrier.m
//  APN Changer
//
//  Created by Michael Weisman on 10/20/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import "APNCarrier.h"


@implementation APNCarrier

@dynamic carrierName;
@dynamic carrierDescription;
@dynamic carrierAPN;
@dynamic apnUsername;
@dynamic apnPassword;

- (NSString *) carrierXML
{
    NSString *xml;
    
    NSError *templateReadError;
    NSString *xmlLoc = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"template.mobileconfig"];
    NSString *templateXML = [NSString stringWithContentsOfFile:xmlLoc encoding:NSUTF8StringEncoding error:&templateReadError];
    
    xml = [templateXML stringByReplacingOccurrencesOfString:@"$$CARRIERDESC$$" withString:self.carrierDescription];
    xml = [xml stringByReplacingOccurrencesOfString:@"$$CARRIERNAME$$" withString:self.carrierName];
    xml = [xml stringByReplacingOccurrencesOfString:@"$$APN$$" withString:self.carrierAPN];
    xml = [xml stringByReplacingOccurrencesOfString:@"$$UUID1$$" withString:[[NSUUID UUID] UUIDString]];
    xml = [xml stringByReplacingOccurrencesOfString:@"$$UUID2$$" withString:[[NSUUID UUID] UUIDString]];
    
    return xml;
}

@end
