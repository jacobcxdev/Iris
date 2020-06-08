//
//  IrisRoundedBorderLayer.h
//  Iris
//
//  Created by Jacob Clayden on 06/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IrisRoundedBorderLayer : CALayer
+ (instancetype _Nonnull)roundedBorderLayerForView:(UIView * _Nonnull)view colour:(CGColorRef _Nonnull)colour;
@end