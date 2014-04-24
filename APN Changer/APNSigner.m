//
//  APNSigner.m
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-21.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import "APNSigner.h"

@implementation APNSigner

+ (NSData *)signMobileconfig:(NSString *)mobileConfig
{
    X509 *cert;
    EVP_PKEY *pkey;
    PKCS7 *pkcs7;
    FILE *fp = NULL;
    BIO *inBio = NULL, *outBio = NULL;
    
    void (^cleanup)() = ^() {
        if (inBio) {
            BIO_free(inBio);
        }
        if (outBio) {
            BIO_free(outBio);
        }
        if (fp) {
            fclose(fp);
        }
    };
    
    OpenSSL_add_all_algorithms ();
    ERR_load_crypto_strings ();
 
    /* read the signer private key */
    NSString *keyLoc = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"key.pem"];
    fp = fopen([keyLoc cStringUsingEncoding:NSUTF8StringEncoding], "r");
    pkey = PEM_read_PrivateKey(fp, NULL, NULL, "davchyricolhobaijtuaneat");
    if (!pkey) {
        ERR_print_errors_fp(stderr);
        NSLog(@"Error reading signer private key");
        cleanup();
        return nil;
    }
    
    /* read the signer certificate */
    NSString *certLoc = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cert.crt"];
    fp = fopen([certLoc cStringUsingEncoding:NSUTF8StringEncoding], "r");
    cert = PEM_read_X509(fp, NULL, NULL, "davchyricolhobaijtuaneat");
    if (!cert) {
        ERR_print_errors_fp (stderr);
        NSLog(@"Error reading signer certificate");
        cleanup();
        return nil;
    }
    
    /* sign the mobileconfig */
    inBio = BIO_new_mem_buf((void *)[mobileConfig cStringUsingEncoding:NSUTF8StringEncoding], -1);
    pkcs7 = PKCS7_sign(cert, pkey, NULL, inBio, 0);
    if (!pkcs7) {
        ERR_print_errors_fp (stderr);
        NSLog(@"Error making the PKCS#7 object");
        cleanup();
        return nil;
    }
    outBio = BIO_new(BIO_s_mem());
    if (SMIME_write_PKCS7(outBio, pkcs7, inBio, 0) != 1) {
        ERR_print_errors_fp (stderr);
        NSLog(@"Error writing the S/MIME data");
        cleanup();
        return nil;
    }
    
    BUF_MEM *bptr;
    BIO_get_mem_ptr(outBio, &bptr);                  //converting memory BIO to BUF_MEM
    BIO_set_close(outBio, BIO_NOCLOSE); /* So BIO_free() leaves BUF_MEM alone */
    
    char *buff = (char *)malloc(bptr->length);        //converting BUF_MEM  to Char *
    memcpy(buff, bptr->data, bptr->length-1);         //to be used later
    buff[bptr->length-1] = 0;
    
    NSString *f = [NSString stringWithUTF8String:buff];
    NSRange range = [f rangeOfString:@"Content-Transfer-Encoding: base64"];
    NSString *substring = [[f substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:substring options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    
    
    cleanup();
    return data;
}
@end
