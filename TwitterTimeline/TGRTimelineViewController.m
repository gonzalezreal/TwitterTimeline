//
//  TGRTimelineViewController.m
//  TwitterTimeline
//
//  Created by guille on 23/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRTimelineViewController.h"
#import "TGRTweetCell.h"
#import "TGRTimeline.h"
#import "TGRTweet.h"

#import "ACAccountStore+Twitter.h"

static NSString * const kTweetCellIdentifier = @"TweetCell";

@interface TGRTimelineViewController ()

@property (strong, nonatomic) TGRTimeline *timeline;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic, getter = isLoading) BOOL loading;

@end

@implementation TGRTimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Timeline", @"");
    
    // Registramos nuestra celda en la tabla
    [self.tableView registerClass:[TGRTweetCell class] forCellReuseIdentifier:kTweetCellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadNewTweets)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.timeline) {
        [self requestTwitterAccess];
    }
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(updateDates:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGRTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetCellIdentifier];
    TGRTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureWithTweet:tweet];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGRTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [TGRTweetCell heightForTweet:tweet];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat distanceToBottom = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height);
    
    self.loading = (distanceToBottom <= 44);
    
    if (distanceToBottom == 0) {
        [self loadOldTweets];
    }
}

#pragma mark - Private methods

- (void)setLoading:(BOOL)loading
{
    if (_loading != loading) {
        _loading = loading;
        
        if (_loading) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.contentMode = UIViewContentModeCenter;
            
            CGRect frame = indicator.frame;
            frame.size.height = 44.0;
            indicator.frame = frame;
            
            [indicator startAnimating];
            
            self.tableView.tableFooterView = indicator;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    }
}

- (void)requestTwitterAccess
{
    ACAccountStore *accountStore = [ACAccountStore tgr_sharedAccountStore];
    
    void (^useTwitterAccount)(void) = ^{
        NSArray *accounts = [accountStore tgr_twitterAccounts];
        
        if ([accounts count]) {
            [self setupTimelineWithAccount:accounts[0]];
        }
        else {
            NSLog(@"There are no Twitter accounts!!");
        }
    };
    
    if ([accountStore tgr_twitterAccountAccessGranted]) {
        useTwitterAccount();
    }
    else {
        [accountStore tgr_requestAccessToTwitterAccountsWithCompletionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), useTwitterAccount);
            }
        }];
    }
}

- (void)setupTimelineWithAccount:(ACAccount *)account
{
    self.timeline = [[TGRTimeline alloc] initWithAccount:account];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[TGRTweet fetchRequestForAllTweets]
                                                                        managedObjectContext:self.timeline.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    [self loadNewTweets];
}

- (void)loadNewTweets
{
    UIRefreshControl *refreshControl = self.refreshControl;
    [refreshControl beginRefreshing];
    
    [self.timeline loadNewTweetsWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error loading new tweets: %@", [error localizedDescription]);
        }
        
        [refreshControl endRefreshing];
    }];
}

- (void)loadOldTweets
{
    [self.timeline loadOldTweetsWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error loading old tweets: %@", [error localizedDescription]);
        }
        
        self.loading = NO;
    }];
}

- (void)updateDates:(NSTimer *)timer
{
    for (TGRTweetCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        TGRTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [cell configureDateLabelWithDate:tweet.publicationDate];
    }
}

@end
