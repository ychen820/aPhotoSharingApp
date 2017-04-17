//
//  YCKbViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/16/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "YCKbViewController.h"
#import "UIView+firstResponder.h"
@interface YCKbViewController ()

@end

@implementation YCKbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.originalFrame=self.view.frame;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     self.originalFrame=self.view.frame;
}
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
    CGFloat keyboardHeight=self.keyboardRect.CGRectValue.size.height;
    NSLog(@"from kb will show kbdtopy:%f,textfieldY%f,differ%f,height %f",keyboardTopY,self.textFieldOrigin.y,differ,keyboardHeight);
    if(self.view.frame.size.height==self.originalFrame.size.height){
        CGRect newFrame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-keyboardHeight);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
