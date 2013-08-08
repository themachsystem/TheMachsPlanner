//
//  AMCoreDataManager.h
//  MachsPlanner
//
//  Created by Alvis Mach on 7/08/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLCategories.h"
#import "TBLPhotos.h"
#import "TBLPlaceLocation.h"
@interface AMCoreDataManager : NSObject
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (AMCoreDataManager*)shareManager;
- (void)setToNil;

- (void)saveContext;
+ (NSURL *)applicationDocumentsDirectory;

/** Methods of fetching core data  go from here*/

/** Returns an array of all data from table TBLCategories*/
- (NSArray*)fetchAllCategories;
/** Returns an array of all data from table TBLPlaceLocation*/
- (NSArray*)fetchPlaceLocationAndDescription;
@end
