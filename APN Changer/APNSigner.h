//
//  APNSigner.h
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-21.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/pem.h>
#import <openssl/pkcs7.h>
#import <openssl/err.h>
#import <openssl/bio.h>
#import <openssl/ssl.h>

@interface APNSigner : NSObject

+ (NSData *)signMobileconfig:(NSString *)mobileConfig;

@end
