//
//  FireBaseManager.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Firebase;
typedef void(^completion)(NSDictionary *dataDict);
@interface FireBaseManager : NSObject
@property(strong ,nonatomic)FIRDatabaseReference *databaseRef;
@property(strong,nonatomic)FIRStorageReference *storageRef;
+(instancetype)sharedFireBaseManager;
-(void)loadAllDataUnderRef:(FIRDatabaseQuery *)databaseRef withCompletion:(completion)handler;
@end
