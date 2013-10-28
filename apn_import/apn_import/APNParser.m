//
//  APNParser.m
//  apn_import
//
//  Created by Michael Weisman on 10/27/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import "APNParser.h"
#import "APNCarrier.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Model";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

@interface APNParser () {
    // Create the managed object context
    NSManagedObjectContext *_context;
    NSString *_country;
    NSString *_carrierName;
    NSMutableString *_currentStringValue;
    NSString *_carrierDescription;
    NSString *_carrierAPN;
    NSString *_apnUser;
    NSString *_apnPass;
    APNCarrier *_carrier;
}
@end

@implementation APNParser

- (id)init
{
    self = [super init];
    if (self) {
        _context = managedObjectContext();
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"country"]) {
        _country = attributeDict[@"code"];
    } else if ([elementName isEqualToString:@"apn"]) {
        _carrierAPN = attributeDict[@"value"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!_currentStringValue) {
        _currentStringValue = [[NSMutableString alloc] init];
    }
    [_currentStringValue appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"name"]) {
        if (!_carrierAPN) {
            _carrierName = _currentStringValue;
        } else {
            _carrierDescription = _currentStringValue;
        }
    } else if ([elementName isEqualToString:@"username"]) {
        _apnUser = _currentStringValue;
    } else if ([elementName isEqualToString:@"password"]) {
        _apnPass = _currentStringValue;
    } else if ([elementName isEqualToString:@"apn"]) {
        _carrier = [NSEntityDescription insertNewObjectForEntityForName:@"APNCarrier"inManagedObjectContext:_context];
        _carrier.carrierName = _carrierName;
        _carrier.carrierDescription = _carrierDescription;
        _carrier.carrierAPN = _carrierAPN;
        _carrier.apnUsername = _apnUser;
        _carrier.apnPassword = _apnPass;
        _carrier.isBuiltIn = YES;
        _carrier.country = _country;
        [self saveAPN];
    }
    
    _currentStringValue = nil;
    _carrier = nil;
}

- (void)saveAPN
{
    // Save the managed object context
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    }
    _carrierDescription = nil;
    _carrierAPN = nil;
    _apnUser = nil;
    _apnPass = nil;
}

@end
