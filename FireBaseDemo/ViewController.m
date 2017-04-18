//
//  ViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/13/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Animate.h"
#import "FormViewController.h"
#import "CustomNavController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIViewController+simpleAlert.h"
@import Firebase;
@import FirebaseDatabase;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property(strong,nonatomic) NSArray *textfields;
@property (weak, nonatomic) IBOutlet UIStackView *formStackView;
@property(nonatomic)Boolean appeared;
@property(nonatomic,strong) FIRDatabaseReference *ref;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref=[[FIRDatabase database]reference];

          // Do any additional setup after loading the view, typically from a nib.
}


-(void)viewDidAppear:(BOOL)animated{
     self.textfields=[NSArray arrayWithObjects:self.emailTextField,self.pwdTextField, nil];
    [super viewDidAppear:animated];
      [self.navigationController setNavigationBarHidden:YES];
    if(!self.appeared){
    [self.topLogo uiMoveAnimationWithOffSet:200 withOptions:0];
    [self.signUpButton uiMoveAnimationWithOffSet:200 withOptions:0];
    [self.loginButton uiMoveAnimationWithOffSet:200 withOptions:0];
        [self.formStackView uiMoveAnimationWithOffSet:200 withOptions:0];
    }
    self.appeared=YES;
}
-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIColor *color = [UIColor whiteColor];
    
    [self.loginButton setTintColor:[UIColor greenColor]];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL" attributes:@{NSForegroundColorAttributeName: color}];
    self.pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: color}];

  
  
}
- (IBAction)forgetPwdAction:(UIButton *)sender {
    [[FIRAuth auth]
     sendPasswordResetWithEmail:self.emailTextField.text
     completion:^(NSError *_Nullable error) {
         if(error==nil){
             [self presentAlertWithTitle:@"Boop" message:@"Password Reset Email Has Been Sent!" buttonTitle:@"OK" withAction:nil];
         }
         else{
             NSLog(@"forgetPwdAction error:%@",error.localizedDescription);
         }
        
     }];
}
- (IBAction)loginAction:(UIButton *)sender {
    BOOL isempty=NO;
    for(UITextField *textfield in self.textfields)
    {
        if(textfield==nil||[textfield.text isEqualToString:@""]){
            [textfield becomeFirstResponder];
            isempty=YES;
        }
    }
    if(!isempty){
        NSString *email=self.emailTextField.text;
        NSString *pwd=self.pwdTextField.text;
        [[FIRAuth auth]signInWithEmail:email password:pwd completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@",error);
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Error"
message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
                CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }];
    }
    
}
- (IBAction)fbLogin:(UIButton *)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login setLoginBehavior:FBSDKLoginBehaviorNative];
    [login
     logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                              credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                              .tokenString];
             [[FIRAuth auth]signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                 if(error){
                     NSLog(@"%@",error.description);
                 }
                 else
                     if ([FBSDKAccessToken currentAccessToken]) {
                         NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                         [parameters setValue:@"id,name,email,picture" forKey:@"fields"];
                         [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                          startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                              NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)result];
                              NSMutableDictionary *publicDict=[[NSMutableDictionary alloc]init];
                              NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",result[@"id"]];
                              [dict setValue:@"facebook" forKey:@"provider"];
                              [dict setValue:pictureURL forKey:@"picture"];
                              [publicDict setValue:dict[@"name"] forKey:@"name"];
                              [publicDict setValue:dict[@"picture"] forKey:@"picture"];

                              if (error==nil) {
                                  
                                  [[[self.ref child:@"users"]child:user.uid]setValue:dict];
                                  [[[self.ref child:@"public"]child:user.uid]setValue:publicDict];
                                  NSLog(@"%@",result);
                                  
                                  
                              }
                          }];
                         CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
                         [self presentViewController:nav animated:YES completion:nil];
                     }
                 NSLog(@"Success");
             }];
             
             
         }
     }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signInAction:(UIButton *)sender {

    CustomNavController *nvc=[self.storyboard instantiateViewControllerWithIdentifier:@"formNav"];
    
    [self presentViewController:nvc animated:YES completion:nil];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
