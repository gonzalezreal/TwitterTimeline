//
//  TGRTwitterUser.h
//  TwitterTimeline
//
//  Created by guille on 17/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRManagedObject.h"

@class TGRTweet;

@interface TGRTwitterUser : TGRManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) NSSet *retweets;

+ (NSFetchRequest *)fetchRequestForTwitterUserWithIdentifier:(NSNumber *)identifier;

+ (id)twitterUserWithIdentifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface TGRTwitterUser (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(TGRTweet *)value;
- (void)removeTweetsObject:(TGRTweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

- (void)addRetweetsObject:(TGRTweet *)value;
- (void)removeRetweetsObject:(TGRTweet *)value;
- (void)addRetweets:(NSSet *)values;
- (void)removeRetweets:(NSSet *)values;

@end
