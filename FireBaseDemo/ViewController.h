//
//  ViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/13/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCKbViewController.h"
@interface ViewController : YCKbViewController
@property (weak, nonatomic) IBOutlet UIImageView *topLogo;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIStackView *mainStack;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

