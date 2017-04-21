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
#import "CustomNavController.h"
@import Firebase;
@interface ProfileViewController ()
@property(nonatomic,strong) FIRDatabaseReference *ref;
@property(nonatomic,strong) NSMutableArray *postsArray;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.feedTableView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0)];
    self.feedTableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
      self.feedTableView.rowHeight=UITableViewAutomaticDimension;
    self.feedTableView.estimatedRowHeight=400;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData:) name:@"upLoadSuccess" object:nil];
     self.ref=[[FIRDatabase database]reference];
    [self initViewWithUserProfile];
    //[self addBlurEffect];
    // Do any additional setup after loading the view.
}
-(void)reloadData:(NSNotification *)notification{
    [self viewWillAppear:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [self loadAllPosts];
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
            if(error==nil){
            [[[self.ref child:@"users"] child:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                // Get user value
                if([snapshot hasChildren]){
               NSString *username=snapshot.value[@"name"];
                self.navigationItem.title=@"Feeds";
                    self.nameLabel.text=username;
                [UIView animateWithDuration:0.5 animations:^{
                    self.nameLabel.alpha=1;
         
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
            }
            else
                NSLog(@"From Profile:Sign In Error %@",error.description);
          
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
#pragma mark - Load Posts From Database
-(void)loadAllPosts{
    self.postsArray=[[NSMutableArray alloc]init];
    FIRDatabaseReference *postsRef=[[self.ref root]child:@"posts"];
    FireBaseManager *sharedManager=[FireBaseManager sharedFireBaseManager];

   [ postsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        for(FIRDataSnapshot *key in [snapshot children]){
       
            
               NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:key.value];
               item[@"key"]=key.key;
            NSLog(@"key:%@,,%@",key.key,key.value);
                [self.postsArray addObject:item];
            
                   }
       self.postsArray=[[[self.postsArray reverseObjectEnumerator]allObjects]mutableCopy];
      
            for(NSMutableDictionary *post in self.postsArray){
                FIRDatabaseReference *authorNameRef=[[[sharedManager.databaseRef root]child:@"public"]child:post[@"author"]];
                [sharedManager loadAllDataUnderRef:authorNameRef withCompletion:^(NSDictionary *dataDict) {
                    post[@"author_name"]=dataDict[@"name"];
                    post[@"author_picture"]=dataDict[@"picture"];
                    [self.feedTableView reloadData];
                }];
                
            }

        
     
               [self.feedTableView reloadData];

      
    }];
    
   }
#pragma mark - TableView Implementations
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.postsArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"feedCell" forIndexPath:indexPath];
    NSInteger arrayCount=[self.postsArray count]-1;
    NSDictionary *currentPost=[self.postsArray objectAtIndex:indexPath.section];
    NSURL *imgURL=[NSURL URLWithString:currentPost[@"image"]];
    NSURL *author_picture=[NSURL URLWithString:currentPost[@"author_picture"]];
   
    NSString *author_name=currentPost[@"author_name"];
    NSString *postKey=currentPost[@"key"];
    FIRDatabaseReference* likesRef =[[FireBaseManager sharedFireBaseManager].databaseRef root];

    
    
    //Check if a post is liked by current user
    cell.postKey=postKey;
    [cell.likeButton setImage:[UIImage imageNamed:@"filled-heart"] forState:UIControlStateSelected];
    likesRef=[[[[likesRef child:@"public"]child:[FIRAuth auth].currentUser.uid ] child:@"likes"]child:postKey];
    [likesRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.value);
        if([snapshot.value isEqual:@YES]){
            NSLog(@"is Liked");
            cell.likeButton.selected=YES;
        }
        else{
            NSLog(@"Not Liked!!");
            cell.likeButton.selected=NO;
        }
    }];
    cell.feedTextLabel.text=[self.postsArray objectAtIndex:indexPath.section][@"text"];

    [cell.authorPicture sd_setImageWithURL:author_picture placeholderImage:[UIImage imageNamed:@"profile-pictures"]];
    cell.authorPicture.layer.cornerRadius=cell.authorPicture.frame.size.height/2;
    cell.authorPicture.layer.masksToBounds=YES;
    cell.authorNameLabel.text=author_name;
    [cell.feedPhotoImageView sd_setImageWithURL:imgURL];
    
    return cell;
}

#pragma mark - Navigation
- (void) addBlurEffect {
    // Add blur view
    CGRect bounds = self.navigationController.navigationBar.bounds;
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.frame = bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.navigationController.navigationBar addSubview:visualEffectView];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar sendSubviewToBack:visualEffectView];
    
    // Here you can add visual effects to any UIView control.
    // Replace custom view with navigation bar in above code to add effects to custom view.
}
// In a storyboard-based application, you will often want to do a little preparation 
- (IBAction)postButtonAction:(UIButton *)sender {
    CustomNavController *navController=[self.storyboard instantiateViewControllerWithIdentifier:@"postNav"];
    [self presentViewController:navController animated:YES completion:nil];
    
}
- (IBAction)likeButtonAction:(UIButton *)sender {
    if(sender.selected){
        
    }
}


@end
