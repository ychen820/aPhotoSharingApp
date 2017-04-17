//
//  YCKbViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCKbViewController : UIViewController
@property (nonatomic)CGPoint textFieldOrigin;
@property(strong,nonatomic)NSValue *keyboardRect;
@property(nonatomic) CGRect originalFrame;
-(void)keyboardWillShow :(NSNotification *)notification;
@end
