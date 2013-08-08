//
//  TBLPlaceLocation.h
//  MachsPlanner
//
//  Created by Alvis Mach on 7/08/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBLCategories;

@interface TBLPlaceLocation : NSManagedObject

@property (nonatomic) int16_t colIdPlaceLocation;
@property (nonatomic) int16_t colIdCategories;
@property (nonatomic, retain) NSString * colAddress;
@property (nonatomic, retain) NSString * colPlaceName;
@property (nonatomic) double colLongitude;
@property (nonatomic) double colLatitude;
@property (nonatomic, retain) NSString * colPlaceInfo;
@property (nonatomic, retain) TBLCategories *categories;

@end
