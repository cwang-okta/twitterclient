//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : RestObject

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

- (void)toggleRetweeted;
- (void)toggleFavorited;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *currentUserRetweetId;
@property (nonatomic, strong) NSString *tweetText;
@property (nonatomic, strong) NSString *retweeterUsername;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) NSInteger favoriteCount;

@property (nonatomic, assign) BOOL retweeted;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) BOOL replied;

@property (nonatomic, strong, readonly) NSString *timeAgo;
@property (nonatomic, strong, readonly) NSString *timestamp;

@end
