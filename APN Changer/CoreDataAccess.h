//
//  CoreDataAccess.h
//  APN Changer
//
//  Created by Michael Weisman on 10/20/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataAccess : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;

+ (CoreDataAccess *)sharedInstance;
- (void)saveContext;

@end