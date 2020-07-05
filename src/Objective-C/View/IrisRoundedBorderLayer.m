//
//  IrisRoundedBorderLayer.m
//  Iris
//
//  Created by Jacob Clayden on 06/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import "IrisRoundedBorderLayer.h"

@implementation IrisRoundedBorderLayer
+ (instancetype _Nonnull)roundedBorderLayerForView:(UIView * _Nonnull)view colour:(CGColorRef _Nonnull)colour {
    IrisRoundedBorderLayer *layer = [super layer];
    layer.frame = CGRectMake(-3, -3, view.frame.size.width + 6, view.frame.size.height + 6);
    layer.borderColor = colour;
    layer.borderWidth = 2;
    layer.cornerRadius = layer.frame.size.height / 2;
    return layer;
}
@end