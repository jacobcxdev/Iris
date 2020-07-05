//
//  IrisConversationTag.m
//  Iris
//
//  Created by Jacob Clayden on 05/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import "IrisConversationTag.h"

@interface IrisConversationTag ()
@property (nonatomic, readwrite, copy) NSUUID * _Nonnull uuid;
@end

@implementation IrisConversationTag
+ (BOOL)supportsSecureCoding {
    return true;
}
+ (instancetype _Nonnull)tagWithUUID:(NSUUID * _Nonnull)uuid name:(NSString * _Nonnull)name colour:(UIColor * _Nonnull)colour {
    return [[self alloc] initWithUUID:uuid name:name colour:colour];
}
- (instancetype _Nonnull)initWithUUID:(NSUUID * _Nonnull)uuid name:(NSString * _Nonnull)name colour:(UIColor * _Nonnull)colour {
    self = [super init];
    self.uuid = uuid;
    self.name = name;
    self.colour = colour;
    _unreadCount = 0;
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    NSUUID *uuid = [coder decodeObjectForKey:@"uuid"];
    NSString *name = [coder decodeObjectForKey:@"name"];
    UIColor *colour = [coder decodeObjectForKey:@"colour"];
    return [self initWithUUID:uuid name:name colour:colour];
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_uuid forKey:@"uuid"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_colour forKey:@"colour"];
}
@end