//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "ComposeTweetVC.h"
#import "TweetVC.h"

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;

- (void)onSignOutButton;

@end

@implementation TimelineVC

static NSString *CellIdentifier = @"TweetCell";
static NSString *TWEETS_KEY = @"Tweets";
static const int TAG_OFFSET = 100;
static const int CELL_PADDING = 50;
static const int NUM_TWEETS_PER_PAGE = 20;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Home";
        [self refreshData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation Bar
    self.navigationController.navigationBar.barTintColor = [ UIColor colorWithRed: 0.467 green: 0.725 blue: 0.922 alpha: 1.000 ];
    self.navigationController.navigationBar.tintColor = [ UIColor whiteColor ];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTweetButton)];
    
    // Table View Cell
    UINib *cellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(replyTweet:)
                                                 name:@"ReplyToTweet"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(composeTweet:)
                                                 name:@"ComposeTweet"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(retweetTweet:)
                                                 name:@"Retweet"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoriteTweet:)
                                                 name:@"Favorite"
                                               object:nil];
  
    // Refresh Controls
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

    // Initially load stored data
    NSArray *savedTweets = [[NSUserDefaults standardUserDefaults] objectForKey:TWEETS_KEY];
    if (savedTweets) {
        self.tweets = [[NSMutableArray alloc] initWithCapacity:[savedTweets count]];
        for (id tweet in savedTweets) {
            [self.tweets addObject:[NSKeyedUnarchiver unarchiveObjectWithData:tweet]];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // TODO: create an initWithTweet on TweetCell
    cell.tweet = tweet;
    cell.userName.text = tweet.user.name;
    cell.twitterHandle.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    cell.tweetText.text = tweet.tweetText;
    [cell.profileImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImageURL]];
    cell.profileImage.layer.cornerRadius = 4.0f;
    cell.profileImage.clipsToBounds = YES;
    cell.timestamp.text = tweet.timeAgo;

    if (tweet.retweeterUsername != nil) {
        cell.retweetText.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweeterUsername];
        cell.retweetedHeightConstraint.constant = 17;
    } else {
        cell.retweetText.text = @"";
        cell.retweetedHeightConstraint.constant = 0;
    }
    
    cell.retweetButton.selected = tweet.retweeted;
    cell.favoriteButton.selected = tweet.favorited;
    cell.contentView.tag = TAG_OFFSET + (int)indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    
    NSAttributedString *tweetTextStr = [[NSAttributedString alloc] initWithString:tweet.tweetText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
    
    CGRect tweetCellFrame = [tweetTextStr boundingRectWithSize:CGSizeMake([self getScreenWidth] - CELL_PADDING, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                         context:nil];
    if (tweet.retweeterUsername != nil) {
        return ceilf(tweetCellFrame.size.height + 77);
    } else {
        return ceilf(tweetCellFrame.size.height + 60);
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Tweet *tweet = self.tweets[indexPath.row];
    TweetVC *tweetVC = [[TweetVC alloc] init];
    tweetVC.tweet = tweet;
    
    [self.navigationController pushViewController:tweetVC animated:YES];
}

#pragma mark - Private methods

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)onNewTweetButton {
    [self.navigationController pushViewController:[[ComposeTweetVC alloc] init] animated:YES];
}

- (void)refreshData {
    [self fetchDataWithMaxId:nil];
    [self.refreshControl endRefreshing];
}

- (void)fetchDataWithMaxId:(NSString *)maxId {
    [[TwitterClient instance] homeTimelineWithCount:NUM_TWEETS_PER_PAGE sinceId:nil maxId:maxId success:^(AFHTTPRequestOperation *operation, id response) {
        NSMutableArray *tweetArray = [Tweet tweetsWithArray:response];
        if (self.tweets) {
            [self.tweets addObjectsFromArray:tweetArray];
        } else {
            self.tweets = tweetArray;
        }
        [self.tableView reloadData];
        [self saveData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)replyTweet:(NSNotification *)notification {
    Tweet *tweet = notification.object;
    ComposeTweetVC *composeTweetVC = [[ComposeTweetVC alloc] init];
    
    composeTweetVC.tweet = tweet;
    [self.navigationController pushViewController:composeTweetVC animated:YES];
}

- (void)updateTimelineWithTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
    [self saveData];
}

- (void)composeTweet:(NSNotification *)notification {
    Tweet *tweet = notification.object;
    [self updateTimelineWithTweet:tweet];
}

- (void)retweetTweet:(NSNotification *)notification {
    Tweet *tweet = (Tweet *)notification.object;
    
    if (tweet.retweeted) {
        // Remove Retweet
        [[TwitterClient instance] removeRetweetStatusId:tweet.currentUserRetweetId success:^(AFHTTPRequestOperation *operation, id response) {
            // TODO: Update tweet w/ more recent data

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];

    } else {
        // Add Retweet
        [[TwitterClient instance] retweetStatusId:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            tweet.currentUserRetweetId = response[@"id_str"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    [self.tableView reloadData];
    [self saveData];
}

- (void)favoriteTweet:(NSNotification *)notification {
    Tweet *tweet = (Tweet *)notification.object;
    
    if (tweet.favorited) {
        // Unfavorite
        [[TwitterClient instance] unfavoriteStatusId:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            // TODO: Update tweet w/ more recent data
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // TODO: Add better error handling
            NSLog(@"%@", error);
        }];
    } else {
        // Favorite
        [[TwitterClient instance] favoriteStatusId:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            // TODO: Update tweet w/ more recent data
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    [self.tableView reloadData];
    [self saveData];
}

// Infinite Scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat position = scrollView.contentOffset.y + [self getScreenHeight];
    if (position >= scrollView.contentSize.height) {
        if ([self.tweets count] > 0) {
            Tweet *lastTweet = [self.tweets lastObject];
            [self fetchDataWithMaxId:lastTweet.tweetId];
        } else {
            [self fetchDataWithMaxId:nil];
        }
    }
}

#pragma -

- (void)saveData {
    NSMutableArray *savedTweets = [[NSMutableArray alloc] init];
    for (id tweet in self.tweets) {
        [savedTweets addObject:[NSKeyedArchiver archivedDataWithRootObject:tweet]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:savedTweets forKey:TWEETS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGFloat)getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return screenRect.size.width;
    } else {
        return screenRect.size.height;
    }
}

- (CGFloat)getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return screenRect.size.height;
    } else {
        return screenRect.size.width;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
