//
//  ImagePostViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/18/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ImagePostViewController.h"
#import "CustomNavController.h"
@class FIRStorageReference;
@interface ImagePostViewController ()
@property(strong,nonatomic)UIImagePickerController *ipc;
@end

@implementation ImagePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.ipc=[[UIImagePickerController alloc]init];
    self.ipc.delegate=self;
    self.ipc.allowsEditing=YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
}
-(void)openPhoto{
    self.ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.ipc animated:YES completion:nil];


}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)openCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        self.ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.ipc animated:YES completion:nil];

    
}
- (IBAction)imagePickerAction:(id)sender {
 
    UIAlertController *options=[UIAlertController alertControllerWithTitle:@"Photo" message:@"Please Choose Photo Source" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoAction=[UIAlertAction actionWithTitle:@"Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openPhoto];
    }];
    UIAlertAction *cameraAction=[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [options addAction:photoAction];
    [options addAction:cameraAction];
    [options addAction:cancelAction];
    [self presentViewController:options animated:YES completion:nil];

  }
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    self.feedImageView.image=image;
   [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)postAction:(UIBarButtonItem *)sender {
    FIRDatabaseReference *databaseRef=[[FireBaseManager sharedFireBaseManager].databaseRef root];
    FIRStorageReference *storageRef=[[FireBaseManager sharedFireBaseManager].storageRef root];
    NSTimeInterval timeInsec=[[NSDate date]timeIntervalSince1970];
    databaseRef=[databaseRef child:@"posts"];
    storageRef=[storageRef child:[NSString stringWithFormat:@"images/img_%f.jpg",timeInsec]];
    NSData *imageData=UIImageJPEGRepresentation(self.feedImageView.image, 0.8);
    FIRStorageUploadTask *uploadTask=[storageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if(error){
            NSLog(@"imagePicker:%@",error.description);
        }
        else{
            NSURL *imageURL=metadata.downloadURL;
            NSLog(@"%@",imageURL);
            
            NSDictionary *dict=@{@"image":[imageURL absoluteString],@"author":[FIRAuth auth].currentUser.uid,@"text":self.postTextView.text};
            FIRDatabaseReference *postsRef=[databaseRef childByAutoId];
            NSString *postId=postsRef.key;
            [postsRef setValue:dict];
                [[[[[[databaseRef root]child:@"public"]child:[FIRAuth auth].currentUser.uid]child:@"posts"]child:postId]setValue:@YES];
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"upLoadSuccess" object:nil]];
         }
    }];
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
