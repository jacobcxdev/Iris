#import "Globals.h"

// Conditional Imports

#ifdef IS_PREFS
#import "IrisPreferences-Swift.h"
#else
#import "Iris-Swift.h"
#endif

// Static Functions

NSMutableArray *generateButtonModelsWithTags(NSMutableArray *tagsArray, bool includeHiddenButtonModel, bool includeEditButtonModel) {
    NSMutableArray *buttonModels = [NSMutableArray new];
    IrisFlagTagButtonModel *shownButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Shown conversationTag:nil];
    [buttonModels addObject:shownButtonModel];
    if (includeHiddenButtonModel) {
        IrisFlagTagButtonModel *hiddenButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Hidden conversationTag:nil];
        [buttonModels addObject:hiddenButtonModel];
    }
    IrisFlagTagButtonModel *unreadButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Unread conversationTag:nil];
    [buttonModels addObject:unreadButtonModel];
    for (IrisConversationTag *tag in tagsArray) {
        IrisFlagTagButtonModel *buttonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Tagged conversationTag:tag];
        [buttonModels addObject:buttonModel];
    }
    IrisFlagTagButtonModel *untaggedButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Tagged conversationTag:nil];
    [buttonModels addObject:untaggedButtonModel];
    if (includeEditButtonModel) {
        IrisButtonModel *editButtonModel = [[IrisButtonModel alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis.circle"] tintColour:[UIColor systemBlueColor] isHighlighted:false isSelected:false selectable:false badgeCount:0 badgeHidden:true alpha:1 tag:1 target:nil action:nil];
        [buttonModels addObject:editButtonModel];
    }
    return buttonModels;
}