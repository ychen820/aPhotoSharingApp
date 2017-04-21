//
//  ProfileViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FireBaseManager.h"
#import "FeedsTableViewCell.h"
#import "ImagePostViewController.h"
@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;


@end
