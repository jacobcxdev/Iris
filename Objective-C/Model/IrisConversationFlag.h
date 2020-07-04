//
//  IrisConversationFlag.h
//  Iris
//
//  Created by Jacob Clayden on 02/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, IrisConversationFlag) {
    Shown = 1 << 0,
    Hidden = 1 << 1,
    Tagged = 1 << 2,
    Muted = 1 << 3,
    Unread = 1 << 4
};
