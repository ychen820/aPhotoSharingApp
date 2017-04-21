//
//  CustomNavController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/14/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "CustomNavController.h"

@interface CustomNavController ()
@end

@implementation CustomNavController
UIImageView *navBarHairlineImageView;
- (void)viewDidLoad {
    [super viewDidLoad];
  //  navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationBar];
  //  navBarHairlineImageView.hidden = YES;
    
    [self.navigationBar setBackgroundColor:[UIColor clearColor]];
      // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     
  
}
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
