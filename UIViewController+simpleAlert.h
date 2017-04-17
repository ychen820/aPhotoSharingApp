//
//  UIViewController+simpleAlert.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (simpleAlert)
-(void)presentAlertWithTitle:(NSString *)title message:(NSString*)message buttonTitle:(NSString*)btnTitle withAction:(void(^)())completeAction;
@end
