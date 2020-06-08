//
//  IrisTagCreationAlertCollectionViewController.h
//  Iris
//
//  Created by Jacob Clayden on 21/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Alderis/Alderis-Swift.h>
#import "../Categories/UIKit+Private.h"
#import "Iris-Swift.h"

@interface IrisTagCreationAlertCollectionViewController : _UIAlertControllerTextFieldViewController<UICollectionViewDelegateFlowLayout, HBColorPickerDelegate>
@property (nonatomic, retain) IrisFlagTagButtonCollectionControlModel * _Nonnull flagTagButtonCollectionControlModel;
@property (nonatomic, retain) IrisConversationTag * _Nullable originalTag;
@property (nonatomic, retain) IrisButtonModel * _Nullable selectedButtonModel;
@property (nonatomic, retain) NSArray<IrisConversationTag *> * _Nullable tags;
+ (instancetype _Nonnull)controllerWithTags:(NSArray<IrisConversationTag *> * _Nonnull)tags;
- (instancetype _Nonnull)initWithTags:(NSArray<IrisConversationTag *> * _Nonnull)tags;
- (void)didSelectButton:(IrisButtonModel * _Nonnull)buttonModel;
- (IrisConversationTag * _Nullable)selectedTag;
- (void)setupControlModel;
@end
