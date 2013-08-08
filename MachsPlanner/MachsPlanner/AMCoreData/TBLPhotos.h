//
//  TBLPhotos.h
//  MachsPlanner
//
//  Created by Alvis Mach on 7/08/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBLPhotos : NSManagedObject

@property (nonatomic) int16_t colIdPhotos;
@property (nonatomic, retain) NSString * colPlaceUrl;
@property (nonatomic) int16_t colIdCategories;
@property (nonatomic, retain) NSManagedObject *categories;

@end
