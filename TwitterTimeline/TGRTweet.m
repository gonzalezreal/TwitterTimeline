//
//  TGRTweet.m
//  TwitterTimeline
//
//  Created by guille on 17/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRTweet.h"
#import "TGRTwitterUser.h"


@implementation TGRTweet

@dynamic identifier;
@dynamic publicationDate;
@dynamic text;
@dynamic user;
@dynamic retweetedBy;

+ (NSFetchRequest *)fetchRequestForAllTweets
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO];
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return fetchRequest;
}

+ (id)firstTweetInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    
    return [[context executeFetchRequest:fetchRequest error:NULL] lastObject];
}

+ (id)lastTweetInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO];
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    
    return [[context executeFetchRequest:fetchRequest error:NULL] lastObject];
}

- (void)importValuesFromDictionary:(NSDictionary *)dictionary
{
    self.identifier = dictionary[@"id"];
    
    NSDictionary *retweetedStatus = dictionary[@"retweeted_status"];
    
    NSString *dateString = nil;
    NSDictionary *userDictionary = nil;
    NSDictionary *retweetedByDictionary = nil;
    
    if (retweetedStatus) {
        self.text = retweetedStatus[@"text"];
        
        dateString = retweetedStatus[@"created_at"];
        userDictionary = retweetedStatus[@"user"];
        retweetedByDictionary = dictionary[@"user"];
    }
    else {
        self.text = dictionary[@"text"];
        
        dateString = dictionary[@"created_at"];
        userDictionary = dictionary[@"user"];
    }
    
    self.publicationDate = [[self class] dateFromTwitterDate:dateString];
    
    TGRTwitterUser *user = [TGRTwitterUser twitterUserWithIdentifier:userDictionary[@"id"]
                                              inManagedObjectContext:self.managedObjectContext];
    
    if (!user) {
        user = [TGRTwitterUser importFromDictionary:userDictionary
                             inManagedObjectContext:self.managedObjectContext];
    }
    
    self.user = user;
    
    if (retweetedByDictionary) {
        TGRTwitterUser *retweetedBy = [TGRTwitterUser twitterUserWithIdentifier:retweetedByDictionary[@"id"]
                                                         inManagedObjectContext:self.managedObjectContext];
        
        if (!retweetedBy) {
            retweetedBy = [TGRTwitterUser importFromDictionary:retweetedByDictionary
                                        inManagedObjectContext:self.managedObjectContext];
        }
        
        self.retweetedBy = retweetedBy;
    }
}

+ (NSDate *)dateFromTwitterDate:(NSString *)dateString
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    });
    
    return [dateFormatter dateFromString:dateString];
}

@end
