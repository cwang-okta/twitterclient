//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@interface Tweet ()

@property (nonatomic, strong) NSDate *createdAtDate;
@property (nonatomic, strong) NSDictionary *retweetData;
@property (nonatomic, strong) NSString *text;

@end

@implementation Tweet

NSDateFormatter *dateFormat;

- (id)initWithDictionary:(NSDictionary *)data {
    self = [super initWithDictionary:data];
    if (self) {
        self.tweetId = self.data[@"id_str"];
        self.currentUserRetweetId = self.data[@"current_user_retweet"][@"id_str"];
        self.retweetCount = [self.data[@"retweet_count"] integerValue];
        self.retweeted = [self.data[@"retweeted"] boolValue];
        self.favoriteCount = [self.data[@"favorite_count"] integerValue];
        self.favorited = [self.data [@"favorited"] boolValue];
        self.retweetData = self.data[@"retweeted_status"];
        if (self.retweetData == nil) {
            self.user = [[User alloc] initWithDictionary:self.data[@"user"]];
            self.tweetText = self.data[@"text"];
        } else {
            self.user = [[User alloc] initWithDictionary:self.retweetData[@"user"]];
            self.tweetText= self.retweetData[@"text"];
            self.retweeterUsername = self.data[@"user"][@"name"];
        }
        
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        self.createdAtDate = [dateFormat dateFromString:self.data[@"created_at"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self = [self initWithDictionary:self.data];
    }
    return self;
}

// TODO: move these to a util class
- (NSString *)timeAgo {

    NSInteger timeAgoInSeconds = abs(floor([self.createdAtDate timeIntervalSinceNow]));

    if (timeAgoInSeconds < 60) {
        return [NSString stringWithFormat:@"%is", timeAgoInSeconds];
    } else if (timeAgoInSeconds < 3600) {
        return [NSString stringWithFormat:@"%im", timeAgoInSeconds/60];
    } else if (timeAgoInSeconds < 86400) {
        return [NSString stringWithFormat:@"%ih", timeAgoInSeconds/3600];
    } else if (timeAgoInSeconds < 86400 * 7) {
        return [NSString stringWithFormat:@"%id", timeAgoInSeconds/86400];
    } else {
        [dateFormat setDateFormat:@"MM/dd/yy"];
        return [dateFormat stringFromDate:self.createdAtDate];
    }
}

- (NSString *)timestamp {
    [dateFormat setDateFormat:@"MM/dd/yy, hh:mm a"];
    return [dateFormat stringFromDate:self.createdAtDate];
}

- (void)toggleRetweeted {
    if (!self.retweeted) {
        self.retweeted = YES;
        self.retweetCount += 1;
    } else {
        self.retweeted = NO;
        self.retweetCount -= 1;
    }
}

- (void)toggleFavorited {
    if (!self.favorited) {
        self.favorited = YES;
        self.favoriteCount += 1;
    } else {
        self.favorited = NO;
        self.favoriteCount -= 1;
    }
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
