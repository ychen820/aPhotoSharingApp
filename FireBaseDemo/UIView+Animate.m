//
//  UIView+Animate.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/14/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "UIView+Animate.h"
@implementation UIView (Animate)
-(void)uiMoveAnimationWithOffSet:(NSInteger)offset withOptions:(NSInteger)option{
CGRect original=self.frame;
if(option ==0){
    CGRect new=CGRectMake(original.origin.x, original.origin.y-offset, original.size.width, original.size.height);
    self.frame=new;
    [UIView animateWithDuration:1 animations:^{
        self.frame=original ;
        [self.superview layoutIfNeeded];
    }];
}
if(option ==1){
    CGRect new=CGRectMake(original.origin.x-offset, original.origin.y, original.size.width, original.size.height);
    self.frame=new;
    [UIView animateWithDuration:1 animations:^{
        self.frame=original;
        [self.superview layoutIfNeeded];
        
    }];
}
}
@end
