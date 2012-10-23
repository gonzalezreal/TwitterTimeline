//
//  TGRTweet.h
//  TwitterTimeline
//
//  Created by guille on 17/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRManagedObject.h"

@class TGRTwitterUser;

@interface TGRTweet : TGRManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * publicationDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) TGRTwitterUser *user;
@property (nonatomic, retain) TGRTwitterUser *retweetedBy;

+ (NSFetchRequest *)fetchRequestForAllTweets;

+ (id)firstTweetInManagedObjectContext:(NSManagedObjectContext *)context;
+ (id)lastTweetInManagedObjectContext:(NSManagedObjectContext *)context;

@end
