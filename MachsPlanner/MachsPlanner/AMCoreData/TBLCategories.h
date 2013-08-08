//
//  TBLCategories.h
//  MachsPlanner
//
//  Created by Alvis Mach on 7/08/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBLPhotos, TBLPlaceLocation;

@interface TBLCategories : NSManagedObject

@property (nonatomic) int16_t colIdCategories;
@property (nonatomic, retain) NSString * colCategoryName;
@property (nonatomic, retain) NSString * colCategoryDescription;
@property (nonatomic, retain) TBLPlaceLocation *placeLocation;
@property (nonatomic, retain) TBLPhotos *photos;

@end
