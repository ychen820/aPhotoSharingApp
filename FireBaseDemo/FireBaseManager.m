//
//  FireBaseManager.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FireBaseManager.h"

@implementation FireBaseManager
+(instancetype)sharedFireBaseManager{
    static dispatch_once_t sharedFireBaseToken;
    static FireBaseManager *sharedFireBaseManager=nil;
    dispatch_once(&sharedFireBaseToken, ^{
        sharedFireBaseManager=[[FireBaseManager alloc]init];
    });
    return sharedFireBaseManager;
}
-(void)fireBaseSetup{
    self.ref=[[FIRDatabase database]reference];
    
   /* [[FIRAuth auth]signInWithEmail:@"abc@gmail.com" password:@"iloveios" completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error==nil){
            [[[[self.ref child:@"users"] child:user.uid] child:@"firstName"]setValue:@"Chen"];
        }
    }];
    [[FIRAuth auth]createUserWithEmail:@"abc@gmail.com" password:@"iloveios" completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error==nil){
            NSLog(@"%@",user.uid);
        }
    }];
    [[self.ref child:@"stock" ] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.value);
        
    }];
  */
}
@end
