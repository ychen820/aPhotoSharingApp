//
//  FriendsTableView.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/17/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FriendsTableView.h"
#import "ProfileTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+simpleAlert.h"
@import Firebase;
@interface FriendsTableView ()
@property(nonnull,strong) FIRUser *currentUser;
@property(nonnull,strong) FIRDatabaseReference *ref;
@property(nonnull,strong) NSMutableArray *userArray;
@end

@implementation FriendsTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.ref=[[FIRDatabase database] reference];
    self.currentUser=[[FIRAuth auth]currentUser];
    [self getAllUsers];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)getAllUsers{
    self.userArray=[[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FIRDatabaseQuery *allUsers=[[self.ref child:@"public"]queryLimitedToFirst:10];
        [allUsers observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSLog(@"getAllUsers_snapshot:%@",snapshot.value);
            for(NSString *item in snapshot.value){
                NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:snapshot.value[item]];
                dict[@"uid"]=item;
                if(![item isEqualToString:self.currentUser.uid])
                    [self.userArray addObject:dict];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
        
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.userArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(void)getFriendList{
    [self.userArray removeAllObjects];
    FIRDatabaseReference *friendsRef=[[[self.ref child:@"users"]child:self.currentUser.uid]child:@"friends"];
    [friendsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if([snapshot exists]){
            NSDictionary * dict=snapshot.value;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for(NSString *key in dict){
                    FIRDatabaseReference *userRef=[[self.ref child:@"public"]child:key];
                    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:snapshot.value];
                        dict[@"uid"]=key;
                        [self.userArray addObject:dict];
                        [self.tableView reloadData];
                        
                    }];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
            });
            
            
            
            
            
        }
        
    }];
    [self.tableView reloadData];
    
}
- (IBAction)changeSementAction:(UISegmentedControl *)sender {
    
    if(sender.selectedSegmentIndex==0)
        [self viewDidLoad];
    if(sender.selectedSegmentIndex==1){
        [self getFriendList];
        
}
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell" forIndexPath:indexPath];
    cell.nameLabel.text=[self.userArray objectAtIndex:indexPath.section][@"name"];
   
   
        NSURL *imgURL=[NSURL URLWithString:[self.userArray objectAtIndex:indexPath.section][@"picture"]];

        [cell.profileImage sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"profile-pictures"]options:SDWebImageRefreshCached];
    
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    NSDictionary *currentUser=[self.userArray objectAtIndex:indexPath.section];
     FIRDatabaseReference *friendLocation=[[[[self.ref child:@"users"]child:self.currentUser.uid]child:@"friends"]child:currentUser[@"uid"]];
    [friendLocation observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.value);
        if(![snapshot exists]){  //If the user in the current section is not a friend of the current user
            UIAlertController *friendAlert=[UIAlertController alertControllerWithTitle:@"Confirm Action" message:[NSString stringWithFormat:@"Do you want add %@ as a friend?",currentUser[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
            //Action For Add As a friend
            UIAlertAction *addAction=[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[[[[self.ref child:@"users"]child:[FIRAuth auth].currentUser.uid]child:@"friends"]child:currentUser[@"uid"]]setValue:@YES withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if(error==nil){
                        [self presentAlertWithTitle:@"Boop" message:@"You Are Friends Now" buttonTitle:@"OK" withAction:nil];
                    }
                }];
            }];
            UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [friendAlert addAction:cancelAction];
            [friendAlert addAction:addAction];
            [self presentViewController:friendAlert animated:YES completion:nil];
        }
        else{
            UIAlertController *friendAlert=[UIAlertController alertControllerWithTitle:@"Confirm Action" message:[NSString stringWithFormat:@"Do you want remove %@ from friend list?",currentUser[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
            //Remove from friend list action
            UIAlertAction *removeAction=[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[[[[self.ref child:@"users"]child:[FIRAuth auth].currentUser.uid]child:@"friends"]child:currentUser[@"uid"]]setValue:nil withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if(error==nil){
                        [self presentAlertWithTitle:@"Boop" message:@"Succeefully Removed" buttonTitle:@"OK" withAction:^{
                            [self getFriendList];
                        }];
                    }
                }];
            }];
            UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [friendAlert addAction:removeAction];
            [friendAlert addAction:cancelAction];
            [self presentViewController:friendAlert animated:YES completion:nil];
        }
    }];
  
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
