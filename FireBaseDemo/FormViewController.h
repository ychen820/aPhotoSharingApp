//
//  FormViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/14/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
#pragma mark -KB-related
@property (nonatomic)CGPoint textFieldOrigin;
@property(strong,nonatomic)NSValue *keyboardRect;

@end
