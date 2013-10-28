//
//  main.m
//  apn_import
//
//  Created by Michael Weisman on 10/27/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#include "APNCarrier.h"
#include "APNParser.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        NSInputStream *st = [[NSInputStream alloc] initWithFileAtPath:@"/Users/mweisman/Desktop/APN Changer/mobile-broadband-provider-info/serviceproviders.xml"];
        NSXMLParser *apnParser = [[NSXMLParser alloc] initWithStream:st];
        APNParser *parser = [[APNParser alloc] init];
        apnParser.delegate = parser;
        
        BOOL success = [apnParser parse];
        NSError *err = [apnParser parserError];
    }
    return 0;
}

