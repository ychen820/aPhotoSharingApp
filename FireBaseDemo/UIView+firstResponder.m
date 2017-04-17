//
//  UIView+firstResponder.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "UIView+firstResponder.h"

@implementation UIView (firstResponder)
-(id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    else{
    for (UIView *subView in self.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
        if([subView isKindOfClass:[UIStackView class]]){
            
            UIView *result=[subView findFirstResponder];
            if(result!=nil)
            return result;
            }
        }
    
    }
    return nil;
}

@end
