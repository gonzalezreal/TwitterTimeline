//
//  TGRTimeline.h
//  TwitterTimeline
//
//  Created by guille on 21/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <CoreData/CoreData.h>

@interface TGRTimeline : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

- (id)initWithAccount:(ACAccount *)account;

- (BOOL)loadNewTweetsWithCompletionHandler:(void (^)(NSError *error))completionHandler;

- (BOOL)loadOldTweetsWithCompletionHandler:(void (^)(NSError *error))completionHandler;

@end
