//
//  TGRManagedObject.m
//  TwitterTimeline
//
//  Created by guille on 22/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRManagedObject.h"

@implementation TGRManagedObject

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [fetchRequest setFetchBatchSize:25];
    
    return fetchRequest;
}

+ (id)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (id)importFromDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    TGRManagedObject *object = [self insertNewObjectInManagedObjectContext:context];
    [object importValuesFromDictionary:dictionary];
    
    return object;
}

- (void)importValuesFromDictionary:(NSDictionary *)dictionary
{
    // Must be overridden by subclasses
}

@end
