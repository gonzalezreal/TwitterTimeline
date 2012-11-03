//
//  TGRTweetCell.h
//  TwitterTimeline
//
//  Created by guille on 23/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TGRTweet;
@class TGRProfileImageView;

@interface TGRTweetCell : UITableViewCell

@property (strong, nonatomic) TGRProfileImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *retweetedByLabel;

+ (CGFloat)heightForTweet:(TGRTweet *)tweet;

- (void)configureWithTweet:(TGRTweet *)tweet;
- (void)configureDateLabelWithDate:(NSDate *)date;

@end
