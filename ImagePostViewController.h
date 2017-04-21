//
//  ImagePostViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/18/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCKbViewController.h"
#import "FireBaseManager.h"
#import "ProfileViewController.h"
@class ProfileViewController;
@interface ImagePostViewController : YCKbViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

@end
