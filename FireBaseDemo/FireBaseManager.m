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
-(instancetype)init{
    self=[super init];
    if(self){
         self.databaseRef=[[FIRDatabase database]reference];
        self.storageRef=[[FIRStorage storage]reference];
    }
    return self;
}
-(void)loadAllDataUnderRef:(FIRDatabaseQuery *)databaseRef withCompletion:(completion)handler{
   
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [databaseRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if([snapshot hasChildren]){
                NSDictionary *allData=[NSDictionary dictionaryWithDictionary:snapshot.value];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(allData);
                });

            }
        }];
       
      
    });
   }
@end
