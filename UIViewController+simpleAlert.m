//
//  UIViewController+simpleAlert.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "UIViewController+simpleAlert.h"

@implementation UIViewController (simpleAlert)
-(void)presentAlertWithTitle:(NSString *)title message:(NSString*)message buttonTitle:(NSString*)btnTitle withAction:(void(^)())completeAction{
UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                               message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                           if(completeAction!=nil)             completeAction();
                                                      }];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}
@end
