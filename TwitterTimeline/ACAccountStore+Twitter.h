//
//  ACAccountStore+Twitter.h
//  TwitterTimeline
//
//  Created by guille on 23/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <Accounts/Accounts.h>

@interface ACAccountStore (Twitter)

+ (ACAccountStore *)tgr_sharedAccountStore;

- (BOOL)tgr_twitterAccountAccessGranted;

- (void)tgr_requestAccessToTwitterAccountsWithCompletionHandler:(void (^)(BOOL granted, NSError *error))completionHandler;

- (NSArray *)tgr_twitterAccounts;

@end
