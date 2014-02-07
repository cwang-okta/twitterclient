//
//  ComposeTweetVC.m
//  twitter
//
//  Created by Christine Wang on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ComposeTweetVC.h"

@interface ComposeTweetVC ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *replyUserDetailsView;

@end

@implementation ComposeTweetVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // self.navigationController.navigationBar.tintColor = [ UIColor colorWithRed: 0.467 green: 0.725 blue: 0.922 alpha: 1.000 ];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
    
    if (self.tweet) {
        self.userName.text = self.tweet.user.name;
        self.twitterHandle.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
        [self.userImage setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageURL]];
        self.userImage.layer.cornerRadius = 4.0f;
        self.userImage.clipsToBounds = YES;
    } else {
        // TODO!!!!! new gets hidden
        [self.replyUserDetailsView removeFromSuperview];
        self.replyHeightConstraint.constant = 0;
    }
    
    [self.tweetStatus becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTweetButton {

    if (self.tweetStatus.text == nil) {
        return;
    } else {
        if (self.tweet != nil) {
            // Reply to Tweet
            NSString *tweetText = [NSString stringWithFormat:@"@%@ %@", self.tweet.user.screenName, self.tweetStatus.text];
            [[TwitterClient instance] replyToStatusId:self.tweet.tweetId withStatus:tweetText success:^(AFHTTPRequestOperation *operation, id response) {
                 Tweet *respTweet = [[Tweet alloc] initWithDictionary:response];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ComposeTweet"
                                                                    object:respTweet
                                                                  userInfo:nil];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        } else {
            // New Tweet
            [[TwitterClient instance] tweetStatus:self.tweetStatus.text success:^(AFHTTPRequestOperation *operation, id response) {
                Tweet *respTweet = [[Tweet alloc] initWithDictionary:response];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ComposeTweet"
                                                                    object:respTweet
                                                                  userInfo:nil];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end
