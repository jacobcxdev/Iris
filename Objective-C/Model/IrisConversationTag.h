//
//  IrisConversationTag.h
//  Iris
//
//  Created by Jacob Clayden on 05/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IrisConversationTag : NSObject<NSSecureCoding>
@property (nonatomic, readonly, copy) NSUUID * _Nonnull uuid;
@property (nonatomic, retain) NSString * _Nonnull name;
@property (nonatomic, strong) UIColor * _Nonnull colour;
@property (nonatomic) NSUInteger unreadCount;
+ (instancetype _Nonnull)tagWithUUID:(NSUUID * _Nonnull)uuid name:(NSString * _Nonnull)name colour:(UIColor * _Nonnull)colour;
- (instancetype _Nonnull)initWithUUID:(NSUUID * _Nonnull)uuid name:(NSString * _Nonnull)name colour:(UIColor * _Nonnull)colour;
@end