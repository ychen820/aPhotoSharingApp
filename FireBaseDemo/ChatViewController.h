//
//  ChatViewController.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/22/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#define TYPING_INDICATOR_TIMEOUT 1
#define IMAGE_URL_NOT_SET_KEY @"NOTSET"
@interface ChatViewController : JSQMessagesViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) NSDictionary *recipient;
@end
