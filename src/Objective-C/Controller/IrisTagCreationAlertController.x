//
//  IrisTagCreationAlertController.x
//  Iris
//
//  Created by Jacob Clayden on 19/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import "IrisTagCreationAlertController.h"

@implementation IrisTagCreationAlertController
- (instancetype _Nonnull)init {
    if (self = [super init]) {
        NSArray *tags = @[
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Red" colour:[UIColor systemRedColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Orange" colour:[UIColor systemOrangeColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Yellow" colour:[UIColor systemYellowColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Green" colour:[UIColor systemGreenColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Blue" colour:[UIColor systemBlueColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Purple" colour:[UIColor systemPurpleColor]],
            // [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Indigo" colour:[UIColor systemIndigoColor]],
            // [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Pink" colour:[UIColor systemPinkColor]],
            // [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Teal" colour:[UIColor systemTealColor]],
            [IrisConversationTag tagWithUUID:[NSUUID UUID] name:@"Grey" colour:[UIColor systemGrayColor]]
        ];
        [self setValue:[%c(IrisTagCreationAlertCollectionViewController) controllerWithTags:tags] forKey:@"_textFieldViewController"];
    }
    return self;
}
- (IrisConversationTag * _Nullable)originalTag {
    return ((IrisTagCreationAlertCollectionViewController *)[self valueForKey:@"_textFieldViewController"]).originalTag;
}
- (void)setOriginalTag:(IrisConversationTag * _Nullable)originalTag {
    ((IrisTagCreationAlertCollectionViewController *)[self valueForKey:@"_textFieldViewController"]).originalTag = originalTag;
    [((IrisTagCreationAlertCollectionViewController *)[self valueForKey:@"_textFieldViewController"]) setupControlModel];
}
- (IrisConversationTag * _Nullable)selectedTag {
    return ((IrisTagCreationAlertCollectionViewController *)[self valueForKey:@"_textFieldViewController"]).selectedTag;
}
@end