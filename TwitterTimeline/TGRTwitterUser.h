//
//  TGRTwitterUser.h
//  TwitterTimeline
//
//  Created by guille on 17/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TGRTweet;

@interface TGRTwitterUser : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) NSSet *retweets;
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
