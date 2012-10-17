//
//  TGRTweet.h
//  TwitterTimeline
//
//  Created by guille on 17/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TGRTwitterUser;

@interface TGRTweet : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * publicationDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) TGRTwitterUser *user;
@property (nonatomic, retain) TGRTwitterUser *retweetedBy;

@end
