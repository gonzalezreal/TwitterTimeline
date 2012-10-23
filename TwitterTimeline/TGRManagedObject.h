//
//  TGRManagedObject.h
//  TwitterTimeline
//
//  Created by guille on 22/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TGRManagedObject : NSManagedObject

+ (NSString *)entityName;
+ (NSFetchRequest *)fetchRequest;

+ (id)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)context;
+ (id)importFromDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)importValuesFromDictionary:(NSDictionary *)dictionary;

@end
