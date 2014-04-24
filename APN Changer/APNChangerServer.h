//
//  APNChangerServer.h
//  APN Changer
//
//  Created by Michael Weisman on 10/19/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutingHTTPServer.h"

@interface APNChangerServer : NSObject

@property (readonly) NSNumber *port;

+ (APNChangerServer *)sharedServer;
- (void) stopServer;
- (void) startServer;
- (void) serveXMLString:(NSString *)carrierXML forCarrier:(NSString *)carrierName;
- (void) serveDownloaderForCarrier:(NSString *)carrierName carrierId:(NSString *)carrierID;

@end
