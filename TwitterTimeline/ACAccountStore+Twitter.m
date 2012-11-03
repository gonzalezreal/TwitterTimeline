//
//  ACAccountStore+Twitter.m
//  TwitterTimeline
//
//  Created by guille on 23/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "ACAccountStore+Twitter.h"

@implementation ACAccountStore (Twitter)

+ (ACAccountStore *)tgr_sharedAccountStore
{
    static dispatch_once_t onceToken;
    static ACAccountStore *accountStore;
    
    dispatch_once(&onceToken, ^{
        accountStore = [[ACAccountStore alloc] init];
    });
    
    return accountStore;
}

- (BOOL)tgr_twitterAccountAccessGranted
{
    ACAccountType *twitterType = [self accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [twitterType accessGranted];
}

- (void)tgr_requestAccessToTwitterAccountsWithCompletionHandler:(void (^)(BOOL granted, NSError *error))completionHandler
{
    ACAccountType *twitterType = [self accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self requestAccessToAccountsWithType:twitterType
                                  options:nil
                               completion:completionHandler];
}

- (NSArray *)tgr_twitterAccounts
{
    ACAccountType *twitterType = [self accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [self accountsWithAccountType:twitterType];
}

@end
