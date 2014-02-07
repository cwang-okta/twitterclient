//
//  ComposeTweetVC.h
//  twitter
//
//  Created by Christine Wang on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeTweetVC : UIViewController

@property (nonatomic, strong) Tweet *tweet;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;
@property (strong, nonatomic) IBOutlet UITextView *tweetStatus;

@end
