//
//  APNCarrier.h
//  APN Changer
//
//  Created by Michael Weisman on 10/20/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APNCarrier : NSManagedObject

@property (nonatomic, retain) NSString * carrierName;
@property (nonatomic, retain) NSString * carrierDescription;
@property (nonatomic, retain) NSString * carrierAPN;
@property (nonatomic, readonly) NSString *carrierXML;

@end
