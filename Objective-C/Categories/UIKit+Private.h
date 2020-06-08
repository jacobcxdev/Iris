//
//  UIKit+Private.h
//  Iris
//
//  Created by Jacob Clayden on 19/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _UIAlertControllerTextFieldViewController : UICollectionViewController
@property (readonly) NSArray *textFields;
- (NSInteger)numberOfTextFields;
@end

@interface UIAlertController () {
    _UIAlertControllerTextFieldViewController *_textFieldViewController;
}
@property (nonatomic, strong, readwrite) UIViewController *contentViewController;
@end

@interface UICollectionViewLayout ()
@property (nonatomic, readwrite) CGFloat minimumLineSpacing;
@property (nonatomic, readwrite) CGSize estimatedItemSize;
@end