//
//  TGRProfileImageView.h
//  TwitterTimeline
//
//  Created by guille on 27/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGRProfileImageView : UIView

- (void)setProfileImageURL:(NSURL *)url;
- (void)cancelCurrentImageLoad;

@end
