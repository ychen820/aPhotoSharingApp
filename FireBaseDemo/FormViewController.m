//
//  FormViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/14/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FormViewController.h"
#import "CustomNavController.h"
#import "UIView+firstResponder.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CustomNavController.h"
#import "UIViewController+simpleAlert.h"
@import Firebase;
@interface FormViewController ()
@property(nonatomic) CGRect originalFrame;
@property(nonatomic,strong) NSArray *textFields;
@property(nonatomic,strong) FIRDatabaseReference *ref;
@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavbar];
    self.ref=[[FIRDatabase database]reference];
    
    self.textFields=[NSArray arrayWithObjects:self.nameTextField,self.emailTextField,self.pwdTextField,self.confirmTextField, nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
    

//    [self.navigationItem setHidesBackButton:YES];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    self.originalFrame=self.view.frame;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)leftBarButtonAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark --NavBarSetUp
-(void)setUpNavbar{
    //Set Left Button
   // UIView *leftButtonView=[[UIView alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
    UIImage *backBtnImage=[UIImage imageNamed:@"back"];
    //leftButtonView.userInteractionEnabled=YES;
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.bounds=CGRectMake(0,0, 15, 15);
    [back setImage:backBtnImage forState:UIControlStateNormal];
   // [back setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [back addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
       UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithCustomView:back];
    backButton.title=@"Title";
    [backButton setTintColor:[UIColor blackColor]];
    
   // CGRect screenRect=[[UIScreen mainScreen]bounds];
    self.navigationItem.leftBarButtonItem=backButton;
    self.navigationItem.title=@"Sign Up";

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark-Keyboard Behavior
-(void)keyboardWillShow :(NSNotification *)notification{
    id firstResponder=[self.view findFirstResponder];
    
    CGRect frame=[firstResponder frame];
    CGPoint origin=[firstResponder convertPoint:frame.origin  toView:self.view];
    self.textFieldOrigin=origin;
    self.keyboardRect=(notification.userInfo)[UIKeyboardFrameEndUserInfoKey];
    //CGFloat height=self.keyboardRect.CGRectValue.size.height;
    CGFloat keyboardTopY=self.keyboardRect.CGRectValue.origin.y;
    CGFloat marginToKeyboard=30;
    CGFloat differ=keyboardTopY-marginToKeyboard-self.textFieldOrigin.y;
    
    NSLog(@"from kb will show kbdtopy:%f,textfieldY%f,differ%f",keyboardTopY,self.textFieldOrigin.y,differ);
    if(differ<0&&self.view.frame.origin.y>=0){
        CGRect newFrame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+differ-marginToKeyboard, self.view.frame.size.width, self.view.frame.size.height);
        [self.view setFrame:newFrame];
        [UIView animateWithDuration:0.5 animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
    //CGRect *keyboardRect= notification.userInfo;
}
-(void)keyboardWillDismiss:(NSNotification *)notification{
    self.view.frame=self.originalFrame;
    [UIView animateWithDuration:0.5 animations:^{
        
        [self.view layoutIfNeeded];
    }];
    
}
#pragma mark - SignUp Functions
- (IBAction)signUpAction:(UIButton *)sender {
    for(UITextField *textfield in self.textFields){
        if([textfield.text isEqualToString:@""] || (textfield.text==nil)){
            [textfield becomeFirstResponder];
        }
    }
    NSString *name=self.nameTextField.text;
    NSString *email=self.emailTextField.text;
    NSString *pwd=self.pwdTextField.text;
    NSString *pwdConfirm=self.confirmTextField.text;
    if(![pwd isEqualToString:pwdConfirm]){
        [self presentAlertWithTitle:@"Login Error" message:@"Please Confirm The Password" buttonTitle:@"Continue" withAction:^{
            [self.pwdTextField becomeFirstResponder];
        }];
        
    }
    
    [[FIRAuth auth]createUserWithEmail:email password:pwd completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(!error){
            NSLog(@"%@",user.uid);
            [[FIRAuth auth]signInWithEmail:email password:pwd completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                if(!error){
                [[[self.ref child:@"users"]child:user.uid]setValue:@{@"name":name,@"email":email,@"provider":@"email"}];
                [[[self.ref child:@"public"]child:user.uid]setValue:@{@"name":name}];
                    CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
                    [self presentViewController:nav animated:YES completion:nil];

                }
                
            }];
        }
        else
            [self presentAlertWithTitle:@"Login Error" message:error.localizedDescription buttonTitle:@"Continue" withAction:nil];
    }];
    
}
- (IBAction)fbSignUp:(id)sender {
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
                         [parameters setValue:@"id,name,email" forKey:@"fields"];
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


@end
