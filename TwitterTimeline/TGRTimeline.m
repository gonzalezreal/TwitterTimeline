//
//  TGRTimeline.m
//  TwitterTimeline
//
//  Created by guille on 21/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRTimeline.h"
#import "TGRTweet.h"

#import <Social/Social.h>

@interface TGRTimeline ()

@property (nonatomic, readwrite) BOOL loading;
@property (strong, nonatomic) ACAccount *account;

// Core Data stack
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TGRTimeline

- (id)initWithAccount:(ACAccount *)account
{
    self = [super init];
    if (self) {
        _account = account;
    }
    return self;
}

- (BOOL)loadNewTweetsWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    if (self.loading) {
        return NO;
    }
    
    SLRequest *request = [self requestForNewTweets];
    [self loadTweetsWithRequest:request completionHandler:completionHandler];
    
    return YES;
}

- (BOOL)loadOldTweetsWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    if (self.loading) {
        return NO;
    }
    
    SLRequest *request = [self requestForOldTweets];
    [self loadTweetsWithRequest:request completionHandler:completionHandler];
    
    return YES;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Twitter" ofType:@"mom"];
        
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"Twitter" ofType:@"momd"];
        }
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:self.account.username];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error = nil;
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:url
                                                        options:nil
                                                          error:&error];
        
        if (error) {
            NSLog(@"Error creating the persistent store coordinator: %@", [error localizedDescription]);
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Private methods

static NSString * const kHomeTimelineURL = @"https://api.twitter.com/1.1/statuses/home_timeline.json";

- (SLRequest *)requestForNewTweets
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"include_rts"] = @"true";
    
    TGRTweet *lastTweet = [TGRTweet lastTweetInManagedObjectContext:self.managedObjectContext];
    
    if (lastTweet) {
        parameters[@"since_id"] = [lastTweet.identifier stringValue];
    }
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:kHomeTimelineURL]
                                               parameters:parameters];
    request.account = self.account;
    
    return request;
}

- (SLRequest *)requestForOldTweets
{
    TGRTweet *firstTweet = [TGRTweet firstTweetInManagedObjectContext:self.managedObjectContext];
    
    if (!firstTweet) {
        NSLog(@"requestForOldTweets shouldn't be called when the cache is empty");
        return nil;
    }
    
    NSNumber *maxIdentifier = [NSNumber numberWithLongLong:[firstTweet.identifier longLongValue] - 1];
    
    NSDictionary *parameters = @{
    @"include_rts" : @"true",
    @"max_id" : [maxIdentifier stringValue]
    };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:kHomeTimelineURL]
                                               parameters:parameters];
    request.account = self.account;
    
    return request;
}

- (void)loadTweetsWithRequest:(SLRequest *)request completionHandler:(void (^)(NSError *error))completionHandler
{
    self.loading = YES;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:0
                                                            error:NULL];
            
            if ([response isKindOfClass:[NSArray class]]) {
                [self.managedObjectContext performBlock:^{
                    [self importTweets:response];
                }];
            }
            else {
                NSLog(@"Error: %@", response[@"errors"][0][@"message"]);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading = NO;
            completionHandler(error);
        });
    }];
}

- (void)importTweets:(NSArray *)tweets
{
    for (NSDictionary *tweetDictionary in tweets) {
        [TGRTweet importFromDictionary:tweetDictionary inManagedObjectContext:self.managedObjectContext];
    }
    
    NSError *error = nil;
    BOOL succeeded = [self.managedObjectContext save:&error];
    
    if (!succeeded) {
        NSLog(@"Error saving timeline: %@", [error localizedDescription]);
    }
}

@end
