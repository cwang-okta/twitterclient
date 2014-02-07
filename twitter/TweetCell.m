//
//  TweetCell.m
//  twitter
//
//  Created by Timothy Lee on 8/6/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"
#import "ComposeTweetVC.h"

@interface TweetCell ()

@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)replyToTweet:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReplyToTweet"
                                                        object:self.tweet
                                                      userInfo:nil];
}

- (IBAction)retweet:(id)sender {
    [self.tweet toggleRetweeted];
    self.retweetButton.selected = self.tweet.retweeted;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Retweet"
                                                        object:self.tweet
                                                      userInfo:nil];
}

- (IBAction)favoriteTweet:(id)sender {
    [self.tweet toggleFavorited];
    self.favoriteButton.selected = self.tweet.favorited;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Favorite"
                                                        object:self.tweet
                                                      userInfo:nil];
}

@end
