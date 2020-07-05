//
//  IrisTagCreationAlertController.h
//  Iris
//
//  Created by Jacob Clayden on 19/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IrisTagCreationAlertCollectionViewController.h"
#import "Iris-Swift.h"

@interface IrisTagCreationAlertController : UIAlertController
@property (nonatomic, retain) IrisConversationTag * _Nullable originalTag;
@property (nonatomic, readonly) IrisConversationTag * _Nullable selectedTag;
@end