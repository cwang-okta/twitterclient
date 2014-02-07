//
//  TweetVC.m
//  twitter
//
//  Created by Christine Wang on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetVC.h"
#import "ComposeTweetVC.h"

@interface TweetVC ()

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (strong, nonatomic) IBOutlet UILabel *retweetText;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) IBOutlet UILabel *numRetweets;
@property (strong, nonatomic) IBOutlet UILabel *numFavorites;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *retweetedHeightConstraint;
@end

@implementation TweetVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Tweet";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(onHomeButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReplyButton)];

    // Load Tweet Data
    self.userName.text = self.tweet.user.name;
    self.twitterHandle.text = [NSString stringWithFormat:@"@%@", self.tweet.user.name];
    self.tweetText.text = self.tweet.tweetText;
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageURL]];
    self.profileImage.layer.cornerRadius = 4.0f;
    self.profileImage.clipsToBounds = YES;
    self.timestamp.text = self.tweet.timestamp;
    self.numRetweets.text = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    self.numFavorites.text = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    
    if (self.tweet.retweeterUsername != nil) {
        self.retweetText.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.retweeterUsername];
        self.retweetedHeightConstraint.constant = 17;
    } else {
        self.retweetText.text = @"";
        self.retweetedHeightConstraint.constant = 0;
    }
    
    self.retweetButton.selected = self.tweet.retweeted;
    self.favoriteButton.selected = self.tweet.favorited;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onHomeButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onReplyButton {
    ComposeTweetVC *composeTweetVC = [[ComposeTweetVC alloc] init];
    composeTweetVC.tweet = self.tweet;
    [self.navigationController pushViewController:composeTweetVC animated:YES];
}

- (IBAction)replyToTweet:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReplyToTweet"
                                                        object:self.tweet
                                                      userInfo:nil];
}
- (IBAction)retweet:(id)sender {
    [self.tweet toggleRetweeted];
    self.retweetButton.selected = self.tweet.retweeted;
    self.numRetweets.text = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    
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
