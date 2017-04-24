//
//  ChatViewController.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/22/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ChatViewController.h"
#import "FireBaseManager.h"
#import <JSQMessagesViewController/UIColor+JSQMessages.h>
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessagesViewController/JSQPhotoMediaItem.h>
@import Photos;
@interface ChatViewController ()
@property(strong,nonatomic)NSMutableArray *messages;
@property(strong,nonatomic)JSQMessagesAvatarImage *senderAvatar;
@property(strong,nonatomic)JSQMessagesAvatarImage *receiverAvatar;
@property(strong,nonatomic)NSTimer *indicatorRemover;
@property(strong,nonatomic)UIImagePickerController *ipc;
@property(strong,nonatomic)NSMutableDictionary *photoMessageMap;
@property(nonatomic)FIRDatabaseHandle messageUpdateHandle;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeTyping];
    [self observeIncomingMessages];
    self.photoMessageMap=[[NSMutableDictionary alloc]init];
    self.navigationItem.title=self.recipient[@"name"];
    self.messages=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
          [self loadAvatars];
    }
-(NSString *)sendPhotoMessage{
    FIRDatabaseReference *photoMsgRef=[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:[self getDataBaseLocation]]childByAutoId];
    NSDictionary *msgDict=@{@"photoURL":IMAGE_URL_NOT_SET_KEY,
                            @"senderID":self.senderId};
    [photoMsgRef setValue:msgDict];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    return photoMsgRef.key;
    
}


-(void)textViewDidChange:(UITextView *)textView{
    [super textViewDidChange:textView];
    if(self.indicatorRemover!=nil){
      [ self.indicatorRemover invalidate];
        self.indicatorRemover=nil;
    }
    FIRDatabaseReference *isTypingRef = [[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:@"typeIndicator"]child:self.senderId];
    [isTypingRef setValue:@YES];
    self.indicatorRemover=[NSTimer scheduledTimerWithTimeInterval:TYPING_INDICATOR_TIMEOUT repeats:NO block:^(NSTimer * _Nonnull timer) {
        [isTypingRef removeValue];
        NSLog(@"Removing typing indicatior");
    }];
}

-(void)observeTyping{
    FIRDatabaseReference *isTypingRef = [[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:@"typeIndicator"]child:self.senderId];
    [isTypingRef onDisconnectRemoveValue];
    FIRDatabaseReference *typingMonitor=[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:@"typeIndicator"]child:self.recipient[@"uid"]];
    [typingMonitor observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.value);
        if([snapshot.value isEqual:@YES]){
            self.showTypingIndicator=YES;
            [self scrollToBottomAnimated:YES];
        }
        else
            self.showTypingIndicator=NO;
            }];
}
-(void)addMessageWithID: (NSString *)senderId andName:(NSString *)name andText:(NSString *)text{
   
    JSQMessage *msg=[JSQMessage messageWithSenderId:senderId displayName:name text:text];
    [self.messages addObject:msg];
}
-(void)addPhotoMessageWithID: (NSString *)senderID andKey:(NSString *)key andMediaItem:(JSQPhotoMediaItem *)mediaItem{
   
    JSQMessage *photoMsg=[JSQMessage messageWithSenderId:senderID displayName:senderID media:mediaItem];
    if(mediaItem.image==nil){
        self.photoMessageMap[key]=mediaItem;
    }
    [self.messages addObject:photoMsg];
    [self.collectionView reloadData];
}
-(void)observeIncomingMessages{
    FIRDatabaseReference *ref=[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:[self getDataBaseLocation]];
    FIRDatabaseHandle messageObserver=[ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *msg=snapshot.value;
        if(msg!=nil){
            if(msg[@"senderName"]&&msg[@"text"])
            {
            [self addMessageWithID:msg[@"senderId"] andName:msg[@"senderName"] andText:msg[@"text"]];
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            [self finishReceivingMessage];
            }
            else if(msg[@"photoURL"]){
                JSQPhotoMediaItem *mediaItem=[[JSQPhotoMediaItem alloc]initWithMaskAsOutgoing:self.senderId==msg[@"senderID"]];
                [self addPhotoMessageWithID:msg[@"senderID"] andKey:snapshot.key andMediaItem:mediaItem];
                if([msg[@"photoURL"] hasPrefix:@"https://"])
                [self fetchPhotoWithURL:msg[@"photoURL"] andMediaItem:mediaItem photoMessageKey:nil];
            }
        }
        else{
            NSLog( @"observer error");
        }
    }];
    self.messageUpdateHandle=[ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *updatedMsg=snapshot.value;
        if(updatedMsg[@"photoURL"]&&updatedMsg[@"senderID"]){
            JSQPhotoMediaItem *mediaItem=self.photoMessageMap[snapshot.key];
            [self fetchPhotoWithURL:updatedMsg[@"photoURL"] andMediaItem:mediaItem photoMessageKey:snapshot.key];
        }
    }];
}
-(void)loadAvatars{
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
    [[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"public"]child:self.senderId]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *imgURLStr=snapshot.value[@"picture"];
        if(imgURLStr!=nil){
            NSURL *imgURL=[NSURL URLWithString:imgURLStr];
            NSData *imgData=[NSData dataWithContentsOfURL:imgURL];
            UIImage *image=[UIImage imageWithData:imgData];
            self.senderAvatar=[JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:40];
        }
        [[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"public"]child:self.recipient[@"uid"]]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSString *imgURLStr=snapshot.value[@"picture"];
            if(imgURLStr!=nil){
                NSURL *imgURL=[NSURL URLWithString:imgURLStr];
                NSData *imgData=[NSData dataWithContentsOfURL:imgURL];
                UIImage *image=[UIImage imageWithData:imgData];
                self.receiverAvatar=[JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:40];
                [self.collectionView reloadData];
            }
        }];

    }];
  });
    }

-(NSString *)getDataBaseLocation{
    NSComparisonResult result=[self.senderId compare:self.recipient[@"uid"]];
    NSString *msgLocation;
    if(result == NSOrderedAscending)
        msgLocation=[NSString stringWithFormat:@"%@/%@",self.senderId,self.recipient[@"uid"]];
    else{
        msgLocation=[NSString stringWithFormat:@"%@/%@",self.recipient[@"uid"],self.senderId];
    }
    return msgLocation;
}
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    FIRDatabaseReference *ref=[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:[self getDataBaseLocation]]childByAutoId];
    NSDictionary *msgDict=@{@"text":text,
              @"senderId":senderId,
              @"senderName":senderDisplayName,
                            @"date":[date description]
                            };
    [ref setValue:msgDict];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    FIRDatabaseReference *isTypingRef = [[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"messages"]child:@"typeIndicator"]child:self.senderId];
    [isTypingRef setValue:@NO];
    [self finishSendingMessage];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --Image Picker Methods--
-(void)fetchPhotoWithURL:(NSString *)photoURL andMediaItem:(JSQPhotoMediaItem *)mediaItem photoMessageKey:(NSString *)key{
    FIRStorageReference *photoRef=[[FIRStorage storage]referenceForURL:photoURL];
    [photoRef dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error == nil){
        [photoRef metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error==nil){
                NSLog(@"%@",metadata);
                mediaItem.image=[UIImage imageWithData:data];
                [self.collectionView reloadData];
                if(key!=nil)
                [self.photoMessageMap removeObjectForKey:key];
            }
            else{
                NSLog(@"FetchPhoto_Error%@",error);
            }
        }];
        }
        else{
            NSLog(@"FetchPhoto_Error%@",error);
        }
        
    }];
}
-(void)openPhoto{
    self.ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.ipc animated:YES completion:nil];
    
    
}
-(void)openCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        self.ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.ipc animated:YES completion:nil];
    
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(info[UIImagePickerControllerReferenceURL]!=nil){
        NSURL *pickerRefURL=info[UIImagePickerControllerReferenceURL];
       PHFetchResult *result=[PHAsset fetchAssetsWithALAssetURLs:@[pickerRefURL] options:nil];
        id imageAsset=[result firstObject];
        NSString *key=[self sendPhotoMessage];
       __block NSURL *imageURL=[[NSURL alloc]init];
        [imageAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
           imageURL=contentEditingInput.fullSizeImageURL;
        
        NSString *imagePath=[NSString stringWithFormat:@"images/messages/%@/%@%@",[self getDataBaseLocation],key,imageURL.lastPathComponent];
        FIRStorageReference *storeRef=[[[FireBaseManager sharedFireBaseManager].storageRef root]child:imagePath];
            NSData *imgData=[NSData dataWithContentsOfURL:imageURL];
            [storeRef putData:imgData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error==nil){
                NSString *msgPath=[NSString stringWithFormat:@"messages/%@/%@",[self getDataBaseLocation],key];
                FIRDatabaseReference *msgRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:msgPath];
                [msgRef updateChildValues:@{@"photoURL": [metadata.downloadURL absoluteString]}];
            }
            else
                NSLog(@"ImagePicker Error%@",error.description);
            
        }];
        }];
    }
    else{
        UIImage *image=info[UIImagePickerControllerOriginalImage];
        NSString *key=[self sendPhotoMessage];
        NSData *imageData=UIImageJPEGRepresentation(image, 0.9);
        NSString *imagePath=[NSString stringWithFormat:@"images/messages/%@/%@.jpg",[self getDataBaseLocation],key];
        FIRStorageReference *storeRef=[[[FireBaseManager sharedFireBaseManager].storageRef root]child:imagePath];
      [storeRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
          if(error==nil){
              NSString *msgPath=[NSString stringWithFormat:@"messages/%@/%@",[self getDataBaseLocation],key];
              FIRDatabaseReference *msgRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:msgPath];
              [msgRef updateChildValues:@{@"PhotoURL":metadata.path}];

          }
          else
               NSLog(@"ImagePicker Error%@",error.description);
      }];
        
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ---JSQ Delegate Methods----
-(void)didPressAccessoryButton:(UIButton *)sender{
    self.ipc = [[UIImagePickerController alloc]init];
    self.ipc.delegate=self;
    [self.ipc setAllowsEditing:YES];
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
-(JSQMessagesBubbleImage *) OutgoingBubble{
    JSQMessagesBubbleImageFactory *bubble=[[JSQMessagesBubbleImageFactory alloc]init];
    return [bubble outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
}
-(JSQMessagesBubbleImage *) IncomingBubble{
    JSQMessagesBubbleImageFactory *bubble=[[JSQMessagesBubbleImageFactory alloc]init];
    return [bubble incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}
-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *msg=self.messages[indexPath.item];
    
    if([msg.senderId isEqualToString:self.senderId]){
        return [self OutgoingBubble];
    }
    else{
        return [self IncomingBubble];
    }
}
-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *msg=self.messages[indexPath.item];
    
    if([msg.senderId isEqualToString:self.senderId])
        return self.senderAvatar;
    else
        return self.receiverAvatar;
    return nil;
}
-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.messages objectAtIndex:indexPath.item];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.messages count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessagesCollectionViewCell *cell=[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *msg=self.messages[indexPath.item];
    if([msg.senderId isEqualToString: self.senderId]){
        cell.textView.textColor=[UIColor whiteColor];
        
    }
    else{
        cell.textView.textColor=[UIColor blackColor];
        
    }
    return cell;
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
