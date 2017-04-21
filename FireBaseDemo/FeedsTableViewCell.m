//
//  FeedsTableViewCell.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/18/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FeedsTableViewCell.h"
#import "FireBaseManager.h"
@implementation FeedsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)likeAction:(UIButton *)sender {
            FIRDatabaseReference *publicLikeRef=[[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"public"]child:[FIRAuth auth].currentUser.uid]child:@"likes"]child:self.postKey];
    if(sender.selected){

        [publicLikeRef setValue:nil];
         FIRDatabaseReference *postLikeRef=[[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"posts"]child:self.postKey]child:@"likes"]child:[FIRAuth auth].currentUser.uid];
        [postLikeRef setValue:@NO];
        sender.selected=NO;
    }
    else{
        [publicLikeRef setValue:@YES];
        FIRDatabaseReference *postLikeRef=[[[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"posts"]child:self.postKey]child:@"likes"]child:[FIRAuth auth].currentUser.uid];
        [postLikeRef setValue:@YES];
        sender.selected=YES;
    }
}

@end
