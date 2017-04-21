//
//  FeedsTableViewCell.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/18/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface FeedsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *feedPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *authorPicture;
@property (weak, nonatomic) IBOutlet UILabel *feedTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property(strong,nonatomic) NSString * postKey;
@end
