#import <Foundation/Foundation.h>

// Static Variables

static NSString *defaultFlagKey = @"com.jacobcxdev.iris.defaultFlag";
static NSString *defaultTagUUIDKey = @"com.jacobcxdev.iris.defaultTagUUID";
static NSString *tagsArrayKey = @"com.jacobcxdev.iris.tagsArray";
static NSString *userDefaultsDidUpdateNotificationName = @"com.jacobcxdev.iris.userDefaults.didUpdate";

// Static Functions

NSMutableArray *generateButtonModelsWithTags(NSMutableArray *tagsArray, bool includeHiddenButtonModel, bool includeEditButtonModel);