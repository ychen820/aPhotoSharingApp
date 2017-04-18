//
//  ProfileViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ProfileViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@import Firebase;
@interface ProfileViewController ()
@property(nonatomic,strong) FIRDatabaseReference *ref;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.ref=[[FIRDatabase database]reference];
    [self initViewWithUserProfile];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViewWithUserProfile{
    
    if ([FBSDKAccessToken currentAccessToken]){
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth]signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            [[[self.ref child:@"users"] child:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                // Get user value
                if([snapshot hasChildren]){
               NSString *username=snapshot.value[@"name"];
                self.navigationItem.title=@"Profile";
                    self.nameLabel.text=username;
                [UIView animateWithDuration:0.5 animations:^{
                    self.nameLabel.alpha=1;
                    self.welcomeLabel.alpha=1;
                }];
                }
                else{
                    NSLog(@"Can'f find name in Database");
                    [self logOutAction:nil];
                }
                // ...
            } withCancelBlock:^(NSError * _Nonnull error) {
                NSLog(@"%@", error.localizedDescription);
            }];
          
        }];

    }
  else if([[FIRAuth auth]currentUser])
  {
      FIRUser *user=[[FIRAuth auth]currentUser];
      [[[self.ref child:@"users"] child:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
          // Get user value
          NSString *username=snapshot.value[@"name"];
          self.nameLabel.text=username;
          self.navigationItem.title=@"Profile";
          [UIView animateWithDuration:0.5 animations:^{
              
              self.welcomeLabel.alpha=1;
              self.nameLabel.alpha=1;
          }];

      }];
  }
}
- (IBAction)friendsListButtonAction:(UIBarButtonItem *)sender {
    
    
}
- (IBAction)logOutAction:(UIBarButtonItem *)sender {
    if([FBSDKAccessToken currentAccessToken]){
        FBSDKLoginManager *manager=[[FBSDKLoginManager alloc]init];
        
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        [manager logOut];
    }
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];

    
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
