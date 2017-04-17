//
//  FireBaseManager.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@import FirebaseDatabase;
@interface FireBaseManager : NSObject
@property(strong ,nonatomic)FIRDatabaseReference *ref;
+(instancetype)sharedFireBaseManager;

@end
