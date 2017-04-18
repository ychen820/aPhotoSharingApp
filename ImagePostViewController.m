//
//  ImagePostViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/18/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ImagePostViewController.h"

@interface ImagePostViewController ()

@end

@implementation ImagePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
}
- (IBAction)imagePickerAction:(id)sender {
    UIImagePickerController *ipc=[[UIImagePickerController alloc]init];
    ipc.delegate=self;
    ipc.allowsEditing=YES;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:ipc animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    self.imgView.image=image;
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
