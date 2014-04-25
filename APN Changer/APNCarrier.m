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
@dynamic country;
@dynamic isBuiltIn;

- (NSString *) carrierXML
{
    NSString* (^xml_escape)(NSString*) = ^NSString*(NSString* valueString) {
        NSString *s = [NSString stringWithString:valueString];
        s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
        s = [s stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
        s = [s stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        s = [s stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        s = [s stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        return s;
    };
    
    NSString *xml;
    
    NSError *templateReadError;
    NSString *xmlLoc = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"template.mobileconfig"];
    NSString *templateXML = [NSString stringWithContentsOfFile:xmlLoc encoding:NSUTF8StringEncoding error:&templateReadError];
    
    NSString *escapedDesc =  xml_escape(self.carrierDescription);
    xml = [templateXML stringByReplacingOccurrencesOfString:@"$$CARRIERDESC$$" withString:escapedDesc];
    
    NSString *escapedName =  xml_escape(self.carrierName);
    xml = [xml stringByReplacingOccurrencesOfString:@"$$CARRIERNAME$$" withString:escapedName];
    
    NSString *escapedApn =  xml_escape(self.carrierAPN);
    xml = [xml stringByReplacingOccurrencesOfString:@"$$APN$$" withString:escapedApn];
    
    if (self.apnUsername) {
        NSString *escapedUser =  xml_escape(self.apnUsername);
        NSString *userXML = [NSString stringWithFormat:@"<key>username</key><string>%@</string>", escapedUser];
        xml = [xml stringByReplacingOccurrencesOfString:@"$$USER$$" withString:userXML];
    }
    if (self.apnPassword) {
        NSString *escapedPass =  xml_escape(self.apnPassword);
        NSString *userXML = [NSString stringWithFormat:@"<key>password</key><string>%@</string>",escapedPass];
        xml = [xml stringByReplacingOccurrencesOfString:@"$$PASS$$" withString:userXML];
    }
    xml = [xml stringByReplacingOccurrencesOfString:@"$$UUID1$$" withString:[[NSUUID UUID] UUIDString]];
    xml = [xml stringByReplacingOccurrencesOfString:@"$$UUID2$$" withString:[[NSUUID UUID] UUIDString]];
    
    return xml;
}

@end
