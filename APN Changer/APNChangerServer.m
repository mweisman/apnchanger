//
//  APNChangerServer.m
//  APN Changer
//
//  Created by Michael Weisman on 10/19/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import "APNChangerServer.h"

@implementation APNChangerServer

RoutingHTTPServer *_webServer;

+ (APNChangerServer *)sharedServer
{
    static dispatch_once_t once;
    static id sharedServer;
    dispatch_once(&once, ^{
        sharedServer = [[self alloc] init];
        _webServer = [[RoutingHTTPServer alloc] init];
        [_webServer setDefaultHeader:@"Server" value:@"APNChanger/1.0"];
        _webServer.port = 8888;
        _webServer.type = @"_http._tcp.";
    });
    return sharedServer;
}

- (void) startServer
{
	NSError *error;
	if(![_webServer start:&error]) {
		NSLog(@"Error starting HTTP Server: %@", error);
	}

}

- (void) stopServer
{
    [_webServer stop];
}

- (NSNumber *) port
{
    return [NSNumber numberWithInt:_webServer.listeningPort];
}

- (void) serveXMLString:(NSString *)carrierXML
{
    [_webServer handleMethod:@"GET" withPath:@"/apns/apn.mobileconfig" block:^(RouteRequest *request, RouteResponse *response) {
        [response setHeader:@"Content-Type" value:@"application/x-apple-aspen-config"];
        [response respondWithString:carrierXML];
    }];
}

@end
