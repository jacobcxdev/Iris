//
//  IrisTagCreationAlertCollectionViewController.x
//  Iris
//
//  Created by Jacob Clayden on 21/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import "IrisTagCreationAlertCollectionViewController.h"
#import "../Categories/NSString+Compatibility.h"

@interface IrisTagCreationAlertCollectionViewController ()
@property (nonatomic, retain) UIWindow * _Nullable colourPickerWindow;
@end

%subclass IrisTagCreationAlertCollectionViewController : _UIAlertControllerTextFieldViewController<UICollectionViewDelegateFlowLayout, HBColorPickerDelegate>
%property (nonatomic, retain) UIWindow *colourPickerWindow;
%property (nonatomic, retain) IrisFlagTagButtonCollectionControlModel *flagTagButtonCollectionControlModel;
%property (nonatomic, retain) IrisConversationTag *originalTag;
%property (nonatomic, retain) IrisButtonModel *selectedButtonModel;
%property (nonatomic, retain) NSArray *tags;
%new
+ (instancetype)controllerWithTags:(NSArray<IrisConversationTag *> * _Nonnull)tags {
    return [[self alloc] initWithTags:tags];
}
%new
- (instancetype)initWithTags:(NSArray<IrisConversationTag *> * _Nonnull)tags {
    if ((self = [self init])) {
        self.tags = tags;
        [self setupControlModel];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = %orig;
    return self;
}
- (void)viewDidLoad {
    %orig;
    [self.collectionView registerClass:[IrisFlagTagButtonCollectionControlCell class] forCellWithReuseIdentifier:@"IrisFlagTagButtonCollectionControlCell"];
    self.collectionView.scrollEnabled = false;
    self.collectionView.backgroundColor = nil;
    self.collectionViewLayout.minimumLineSpacing = 7;
}
- (NSInteger)numberOfTextFields {
    return %orig + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        IrisFlagTagButtonCollectionControlCell *cell = (IrisFlagTagButtonCollectionControlCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IrisFlagTagButtonCollectionControlCell" forIndexPath:indexPath];
        [cell initPostDequeueWithControlModel:self.flagTagButtonCollectionControlModel];
        return cell;
    }
    return indexPath.section == 0 ? %orig(collectionView, [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]) : %orig;
}
%new
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row == 0 ? CGSizeMake(self.collectionViewLayout.estimatedItemSize.width, 30) : self.collectionViewLayout.estimatedItemSize;
}
%new
- (void)setupControlModel {
    SEL action = @selector(didSelectButton:);
    NSMutableArray *buttonModels = [NSMutableArray new];
    for (IrisConversationTag *tag in self.tags) {
        IrisFlagTagButtonModel *buttonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Tagged conversationTag:tag];
        [buttonModels addObject:buttonModel];
    }
    IrisButtonModel *customButtonModel = [[IrisButtonModel alloc] initWithImage:[UIImage systemImageNamed:@"plus.circle.fill"] tintColour:self.originalTag ? self.originalTag.colour : [UIColor systemBlueColor] isHighlighted:false isSelected:self.originalTag selectable:true badgeCount:0 badgeHidden:true alpha:1 tag:1 target:self action:action];
    [buttonModels addObject:customButtonModel];
    for (IrisButtonModel *buttonModel in buttonModels) {
        buttonModel.target = self;
        buttonModel.action = action;
    }
    self.flagTagButtonCollectionControlModel = [[IrisFlagTagButtonCollectionControlModel alloc] initWithButtonModels:buttonModels];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}
%new
- (IrisConversationTag * _Nullable)selectedTag {
    NSUInteger idx = [self.flagTagButtonCollectionControlModel.buttonModels indexOfObjectPassingTest:^BOOL(IrisButtonModel *obj, NSUInteger idx, BOOL *stop) {
        return obj.isSelected == true;
    }];
    IrisConversationTag *tag = [IrisConversationTag tagWithUUID:[NSUUID UUID] name:self.originalTag ? self.originalTag.name : @"Other" colour:[UIColor systemBlueColor]];
    if (idx != NSNotFound) {
        IrisButtonModel *buttonModel = self.flagTagButtonCollectionControlModel.buttonModels[idx];
        if ([buttonModel isKindOfClass:[IrisFlagTagButtonModel class]] && ((IrisFlagTagButtonModel *)buttonModel).conversationTag) {
            tag.name = ((IrisFlagTagButtonModel *)buttonModel).conversationTag.name;
            tag.colour = ((IrisFlagTagButtonModel *)buttonModel).conversationTag.colour;
        } else {
            tag.colour = buttonModel.tintColour;
        }
    }
    NSString *name = [((UITextField *)[self.textFields firstObject]).text compatibilityString];
    if (![name isEqualToString:@""]) {
        tag.name = name;
    }
    return tag;
}
%new
- (void)didSelectButton:(IrisButtonModel * _Nonnull)buttonModel {
    self.selectedButtonModel = buttonModel;
    if (self.textFields.count > 0) {
        ((UITextField *)self.textFields[0]).placeholder = [buttonModel isKindOfClass:[IrisFlagTagButtonModel class]] && ((IrisFlagTagButtonModel *)buttonModel).conversationTag ? ((IrisFlagTagButtonModel *)buttonModel).conversationTag.name : self.originalTag ? self.originalTag.name : @"Other";
    }
    if (buttonModel.tag == 1 && UIApplication.sharedApplication.connectedScenes.count > 0) {
        UIWindowScene *windowScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                windowScene = (UIWindowScene *)scene;
            }
        }
        if (windowScene) {
            UIViewController *viewController = [UIViewController new];
            self.colourPickerWindow = [[UIWindow alloc] initWithWindowScene:windowScene];
            self.colourPickerWindow.rootViewController = viewController;
            self.colourPickerWindow.windowLevel = UIWindowLevelAlert + 1000;
            [self.colourPickerWindow makeKeyAndVisible];

            HBColorPickerViewController *colourPicker = [HBColorPickerViewController new];
            colourPicker.color = buttonModel.tintColour;
            colourPicker.delegate = self;
            [viewController presentViewController:colourPicker animated:true completion:nil];
        }
    }
}
%new
- (void)colorPicker:(HBColorPickerViewController * _Nonnull)colorPicker didSelectColor:(UIColor * _Nonnull)color {
    [colorPicker dismissViewControllerAnimated:true completion:^{
        self.colourPickerWindow.hidden = true;
        self.colourPickerWindow = nil;
    }];
    self.selectedButtonModel.tintColour = color;
    for (IrisFlagTagButtonCollectionControlCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[IrisFlagTagButtonCollectionControlCell class]]) {
            [(IrisFlagTagButtonCollectionControlCell *)cell updateControlWithAnimated:true];
        }
    }
}
%new
- (void)colorPickerDidCancel:(HBColorPickerViewController * _Nonnull)colorPicker {
    [colorPicker dismissViewControllerAnimated:true completion:^{
        self.colourPickerWindow.hidden = true;
        self.colourPickerWindow = nil;
    }];
}
%end