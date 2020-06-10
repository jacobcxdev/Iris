//
//  Tweak.x
//  Iris
//
//  Created by Jacob Clayden on 08/02/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import "Tweak.h"
#import <PAC.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <libJCX/Utilities.h>
#import "../View/IrisAvatarCollectionViewCell.h"
#import "../View/IrisRoundedBorderLayer.h"
#import "../Controller/IrisTagListTableViewController.h"

// MobileSubstrate

typedef void (*MSHookMemory_t)(void *, const void *, size_t);
static MSHookMemory_t MSHookMemory;

// Static Variables

static bool shouldShowButton = true;
static NSString *shouldShowButtonKey = @"shouldShowButton";
static bool shouldToggleWhenShaken = false;
static NSString *shouldToggleWhenShakenKey = @"shouldToggleWhenShaken";
static bool shouldToggleWhenVolumePressedSimultaneously = false;
static NSString *shouldToggleWhenVolumePressedSimultaneouslyKey = @"shouldToggleWhenVolumePressedSimultaneously";
static bool shouldToggleWhenRingerSwitched = false;
static NSString *shouldToggleWhenRingerSwitchedKey = @"shouldToggleWhenRingerSwitched";
static bool shouldHideUnknownSenders = false;
static NSString *shouldHideUnknownSendersKey = @"shouldHideUnknownSenders";
static bool shouldHideHiddenUnreadCountFromSBBadge = false;
static NSString *shouldHideHiddenUnreadCountFromSBBadgeKey = @"shouldHideHiddenUnreadCountFromSBBadge";
static bool shouldHideButtonBadge = false;
static NSString *shouldHideButtonBadgeKey = @"shouldHideButtonBadge";
static bool shouldSecureHiddenList = false;
static NSString *shouldSecureHiddenListKey = @"shouldSecureHiddenList";
static bool shouldShowButtonAfterAuthentication = false;
static NSString *shouldShowButtonAfterAuthenticationKey = @"shouldShowButtonAfterAuthentication";
static bool shouldAutoHideHiddenList = false;
static NSString *shouldAutoHideHiddenListKey = @"shouldAutoHideHiddenList";
static bool shouldHideSwipeActions = false;
static NSString *shouldHideSwipeActionsKey = @"shouldHideSwipeActions";
static bool isQuickSwitchEnabled = true;
static NSString *isQuickSwitchEnabledKey = @"isQuickSwitchEnabled";

static IrisConversationFlag currentFlag = Shown;
static NSString *currentFlagKey = @"com.jacobcxdev.iris.currentFlag";
static IrisConversationTag *currentTag;
static NSString *currentTagKey = @"com.jacobcxdev.iris.currentTag";
static NSString *defaultNavigationBarTitle;

static UIWindow *blurWindow;
static bool isAuthenticated = false;
static bool shouldHideCurrentConversation = false;

static NSUInteger shownUnreadCount = 0;
static NSString *shownUnreadCountKey = @"shownUnreadCount";
static NSUInteger hiddenUnreadCount = 0;
static NSString *hiddenUnreadCountKey = @"hiddenUnreadCount";

static NSMutableDictionary<NSString *, NSNumber *> *conversationsFlagsDict;
static NSString *conversationsFlagsDictKey = @"com.jacobcxdev.iris.conversationsFlagsDict";
static NSMutableDictionary<NSString *, NSString *> *conversationsTagDict;
static NSString *conversationsTagDictKey = @"com.jacobcxdev.iris.conversationsTagDict";
static NSMutableArray<IrisConversationTag *> *tagsArray;
static NSString *tagsArrayKey = @"com.jacobcxdev.iris.tagsArray";
static NSMutableArray *pinnedConversationList;
static NSString *pinnedConversationListKey = @"com.jacobcxdev.iris.pinnedConversationList";

static NSString *toggleHiddenListNotificationName = @"com.jacobcxdev.iris.showHiddenList.toggle";
static NSString *localUpdateNotificationName = @"com.jacobcxdev.iris.local.update";
static NSString *localRequestNotificationName = @"com.jacobcxdev.iris.local.request";
static NSString *iCloudPersistNotificationName = @"com.jacobcxdev.iris.iCloud.persist";
static NSString *iCloudRestoreNotificationName = @"com.jacobcxdev.iris.iCloud.restore";
static NSString *userDefaultsDidUpdateNotificationName = @"com.jacobcxdev.iris.userDefaults.didUpdate";

static NSUserDefaults *userDefaults;
static NSUbiquitousKeyValueStore *store;

static NSUInteger ringerSwitchedCount;
static NSDate *lastRingerSwitch;

static void *favouritesSectionSym;
static void *recentsSectionSym;

static JCXNotificationCentre *notificationCentre;
static CKSpringBoardActionManager *actionManager;
static CKConversationListController *ckclc;
static IMDBadgeUtilities *imdbu;
static IrisMenuButton *menuButton;
static UIBarButtonItem *bbi;

// Static Functions

static void updateMenuButtons() {
    NSMutableArray *buttonModels = [NSMutableArray new];
    IrisFlagTagButtonModel *shownButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Shown conversationTag:nil];
    [buttonModels addObject:shownButtonModel];
    IrisFlagTagButtonModel *hiddenButtonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Hidden conversationTag:nil];
    [buttonModels addObject:hiddenButtonModel];
    for (IrisConversationTag *tag in tagsArray) {
        IrisFlagTagButtonModel *buttonModel = [[IrisFlagTagButtonModel alloc] initWithConversationFlag:Tagged conversationTag:tag];
        [buttonModels addObject:buttonModel];
    }
    IrisButtonModel *editButtonModel = [[IrisButtonModel alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis.circle"] tintColour:[UIColor systemBlueColor] isHighlighted:false isSelected:false selectable:false badgeCount:0 badgeHidden:true alpha:1 tag:1 target:nil action:nil];
    [buttonModels addObject:editButtonModel];
    for (IrisButtonModel *buttonModel in buttonModels) {
        buttonModel.target = ckclc;
        buttonModel.action = @selector(didTapMenuButton:);
    }
    NSUInteger idx = [buttonModels indexOfObjectPassingTest:^BOOL(IrisFlagTagButtonModel *obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[IrisFlagTagButtonModel class]] && obj.conversationFlag == currentFlag && ((obj.conversationTag && currentTag && [obj.conversationTag.uuid isEqual:currentTag.uuid]) || (!obj.conversationTag && !currentTag));
    }];
    if (menuButton) {
        [menuButton updateButtonModels:buttonModels topButtonModel:idx != NSNotFound ? buttonModels[idx] : nil animated:true];
    } else {
        menuButton = [[IrisMenuButton alloc] initWithButtonModels:buttonModels topButtonModel:idx != NSNotFound ? buttonModels[idx] : nil itemSize:CGSizeMake(30, 30)];
    }
}

static NSArray *defaultTagsArray() {
    return [@[
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Red" colour:[UIColor systemRedColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Orange" colour:[UIColor systemOrangeColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Yellow" colour:[UIColor systemYellowColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Green" colour:[UIColor systemGreenColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Blue" colour:[UIColor systemBlueColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Purple" colour:[UIColor systemPurpleColor]],
        [[IrisConversationTag alloc] initWithUUID:[NSUUID UUID] name:@"Grey" colour:[UIColor systemGrayColor]]
    ] mutableCopy];
}

static void persistDefaultsState(bool postiCloudNotification) {
    if (!userDefaults) return;
    [userDefaults setInteger:shownUnreadCount forKey:shownUnreadCountKey];
    [userDefaults setInteger:hiddenUnreadCount forKey:hiddenUnreadCountKey];
    [userDefaults setObject:conversationsFlagsDict forKey:conversationsFlagsDictKey];
    [userDefaults setObject:conversationsTagDict forKey:conversationsTagDictKey];
    [userDefaults setObject:pinnedConversationList forKey:pinnedConversationListKey];
    NSError *error = nil;
    NSData *tagsArrayData = [NSKeyedArchiver archivedDataWithRootObject:tagsArray requiringSecureCoding:true error:&error];
    if (!error) {
        [userDefaults setObject:tagsArrayData forKey:tagsArrayKey];
    }
    if (postiCloudNotification) {
        [notificationCentre postNotificationWithName:iCloudPersistNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
    } else {
        [userDefaults setObject:@(currentFlag) forKey:currentFlagKey];
        NSError *error = nil;
        NSData *currentTagData = [NSKeyedArchiver archivedDataWithRootObject:currentTag requiringSecureCoding:true error:&error];
        if (!error) {
            [userDefaults setObject:currentTagData forKey:currentTagKey];
        }
    }
}

static void persistiCloudState() {
    if (!store) return;
    [store setDictionary:conversationsFlagsDict forKey:conversationsFlagsDictKey];
    [store setDictionary:conversationsTagDict forKey:conversationsTagDictKey];
    [store setArray:pinnedConversationList forKey:pinnedConversationListKey];
    NSError *error = nil;
    NSData *tagsArrayData = [NSKeyedArchiver archivedDataWithRootObject:tagsArray requiringSecureCoding:true error:&error];
    if (!error) {
        [store setData:tagsArrayData forKey:tagsArrayKey];
    }
}

static void updateTagsArray(NSMutableArray<IrisConversationTag *> *tags, bool shouldSwitchToShownFlag, bool shouldUpdateMenuButtons, bool shouldPersistDefaultsState) {
    tagsArray = tags;
    [ckclc _switchFlag:shouldSwitchToShownFlag ? Shown : currentFlag tag:shouldSwitchToShownFlag ? nil : currentTag];
    if (shouldPersistDefaultsState) {
        persistDefaultsState(true);
    }
    if (shouldUpdateMenuButtons && menuButton) {
        updateMenuButtons();
    }
}

static void restoreDefaultsState(bool shouldUpdateTagsArray, bool shouldUpdateMenuButtons) {
    if (!userDefaults) return;
    NSUInteger _currentFlag = [[userDefaults objectForKey:currentFlagKey] unsignedIntegerValue];
    currentFlag = shouldSecureHiddenList && _currentFlag == Hidden ? Shown : _currentFlag;
    NSData *currentTagData = [userDefaults dataForKey:currentTagKey];
    currentTag = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[IrisConversationTag class], [NSUUID class], [NSString class], [UIColor class]]] fromData:currentTagData error:nil];
    shownUnreadCount = [userDefaults integerForKey:shownUnreadCountKey];
    hiddenUnreadCount = [userDefaults integerForKey:hiddenUnreadCountKey];
    conversationsFlagsDict = [[userDefaults dictionaryForKey:conversationsFlagsDictKey] mutableCopy] ?: [NSMutableDictionary new];
    conversationsTagDict = [[userDefaults dictionaryForKey:conversationsTagDictKey] mutableCopy] ?: [NSMutableDictionary new];
    pinnedConversationList = [[userDefaults arrayForKey:pinnedConversationListKey] mutableCopy] ?: [NSMutableArray new];
    if (shouldUpdateTagsArray) {
        NSData *tagsArrayData = [userDefaults dataForKey:tagsArrayKey];
        NSMutableArray *_tagsArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[NSMutableArray class], [IrisConversationTag class], [NSUUID class], [NSString class], [UIColor class]]] fromData:tagsArrayData error:nil];
        updateTagsArray(tagsArrayData && _tagsArray ? _tagsArray : [defaultTagsArray() mutableCopy], true, shouldUpdateMenuButtons, false);
    }
}

static void restoreiCloudState(bool shouldUpdateTagsArray, bool shouldUpdateMenuButtons) {
    if (!store) return;
    [store synchronize];
    conversationsFlagsDict = [[store dictionaryForKey:conversationsFlagsDictKey] mutableCopy] ?: [NSMutableDictionary new];
    conversationsTagDict = [[store dictionaryForKey:conversationsTagDictKey] mutableCopy] ?: [NSMutableDictionary new];
    pinnedConversationList = [[store arrayForKey:pinnedConversationListKey] mutableCopy] ?: [NSMutableArray new];
    if (shouldUpdateTagsArray) {
        NSData *tagsArrayData = [store dataForKey:tagsArrayKey];
        NSMutableArray *_tagsArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[NSMutableArray class], [IrisConversationTag class], [NSUUID class], [NSString class], [UIColor class]]] fromData:tagsArrayData error:nil];
        updateTagsArray(tagsArrayData && _tagsArray ? _tagsArray : [defaultTagsArray() mutableCopy], true, shouldUpdateMenuButtons, false);
    }
}

static void updateBadgeCount() {
    if (!menuButton) return;
    if (!shouldHideButtonBadge) {
        [menuButton setBadgeCount:currentFlag == Shown ? hiddenUnreadCount : currentFlag == Tagged && currentTag ? shownUnreadCount + hiddenUnreadCount - currentTag.unreadCount : shownUnreadCount animated:true];
    }
    [menuButton updateButtonBadgesWithShownUnreadCount:shownUnreadCount hiddenUnreadCount:hiddenUnreadCount animated:true];
}

static void updateConversationsFlagsDict(NSString *key, bool condition, IrisConversationFlag flag) {
    if (!conversationsFlagsDict[key]) {
        conversationsFlagsDict[key] = @(0);
    }
    if (condition) {
        conversationsFlagsDict[key] = @([conversationsFlagsDict[key] unsignedIntegerValue] | flag);
    } else {
        conversationsFlagsDict[key] = @([conversationsFlagsDict[key] unsignedIntegerValue] & ~flag);
    }
}

static NSMutableArray *filterConversations(NSArray *conversations, IrisConversationFlag currentFlag, IrisConversationTag *currentTag, bool shouldFilterPinnedConversations, bool updateUnreadCount) {
    NSMutableArray *filteredConversations = [NSMutableArray new];
    NSMutableArray *pendingFilteredConversations = [NSMutableArray new];
    if (updateUnreadCount) {
        shownUnreadCount = 0;
        hiddenUnreadCount = 0;
        for (IrisConversationTag *tag in tagsArray) {
            tag.unreadCount = 0;
        }
    }
    for (CKConversation *conversation in conversations) {
        bool allowed = false;
        bool hidden = conversation.shouldHide;
        bool hiddenForTag = shouldSecureHiddenList && hidden;
        bool muted = conversation.muted;
        switch (currentFlag) {
        case Hidden:
            if (hidden) {
                allowed = true;
            }
            break;
        case Tagged:
            if ([conversation tagMatchesTag:currentTag] && !hiddenForTag) {
                allowed = true;
            }
            break;
        default:
            if (!hidden) {
                allowed = true;
            }
            break;
        }
        if (allowed) {
            if (shouldFilterPinnedConversations && conversation.pinned) {
                [filteredConversations addObject:conversation];
            } else {
                [pendingFilteredConversations addObject:conversation];
            }
        }
        if (updateUnreadCount) {
            if (hidden && !muted) {
                hiddenUnreadCount += conversation.unreadCount;
            } else if (!muted) {
                shownUnreadCount += conversation.unreadCount;
            }
            if (!muted && !hiddenForTag && conversation.tag) {
                conversation.tag.unreadCount += conversation.unreadCount;
            }
        }
    }
    [filteredConversations sortUsingComparator:^NSComparisonResult(CKConversation* a, CKConversation* b) {
        return [[a pinnedIndex] compare:[b pinnedIndex]];
    }];
    [filteredConversations addObjectsFromArray:pendingFilteredConversations];
    if (updateUnreadCount) {
        updateBadgeCount();
        [notificationCentre postNotificationUsingPostHandlerWithName:localUpdateNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
    }
    return filteredConversations;
}

// Mockup Hooks

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
%group Mockup
%hook CNUIPRLikenessLookup
- (id)photoFutureForContactFuture:(id)contactFuture scheduler:(id)scheduler {
    return nil;
}
- (id)photoFutureForContactFuture:(id)contactFuture photoFuture:(id)photoFuture allowingFallbackForMeCard:(bool)allowingFallbackForMeCard {
    return nil;
}
- (id)blessedPhotoObservableWithFuture:(id)photoFuture contact:(CNContact *)contact workScheduler:(id)workScheduler {
    return nil;
}
%end

%hook UIDateLabel
- (void)setText:(NSString *)text {
    return %orig(@"01/01/01");
}
%end

%hook IMChat
- (NSString *)displayName {
    return @"John Appleseed";
}
%end

%hook CKConversation
- (BOOL)hasDisplayName {
    return true;
}
- (NSString *)previewText {
    return @"Buy Iris on Chariz!";
}
%end
%end
#pragma clang diagnostic pop
#pragma clang diagnostic pop

// Messages Hooks

%group Messages
%hook IMChatRegistry
- (IMChat *)existingChatWithGUID:(id)guid {
    IMChat *orig = %orig;
    CKConversation *conversation = [[%c(CKConversationList) sharedConversationList] _conversationForChat:orig];
    return !conversation.shouldHide || currentFlag == Hidden ? orig : nil;
}
%end

%hook CKConversation
+ (BOOL)pinnedConversationsEnabled {
    return true;
}
- (BOOL)isPinned {
    return [pinnedConversationList containsObject:[self uniqueIdentifier]];
}
- (void)setPinned:(BOOL)pinned {
    if (pinned) {
        [pinnedConversationList addObject:[self uniqueIdentifier]];
    } else {
        [pinnedConversationList removeObject:[self uniqueIdentifier]];
    }
    persistDefaultsState(true);
    return %orig;
}
%new
- (NSNumber *)pinnedIndex {
    return @([pinnedConversationList indexOfObject:[self uniqueIdentifier]]);
}
- (BOOL)isMuted {
    BOOL orig = %orig;
    bool muted = (([conversationsFlagsDict[[self uniqueIdentifier]] unsignedIntegerValue] ?: 0) & Muted) != 0;
    if (orig ^ muted) {
        [self setMutedUntilDate:[NSDate distantFuture]];
    }
    return muted;
}
- (void)setMutedUntilDate:(NSDate *)date {
    updateConversationsFlagsDict([self uniqueIdentifier], true, Muted);
    persistDefaultsState(true);
    return %orig;
}
- (void)unmute {
    updateConversationsFlagsDict([self uniqueIdentifier], false, Muted);
    persistDefaultsState(true);
    return %orig;
}
%new
- (BOOL)isShown {
    return (([conversationsFlagsDict[[self uniqueIdentifier]] unsignedIntegerValue] ?: 0) & Shown) != 0;
}
%new
- (void)setShown:(BOOL)shown {
    updateConversationsFlagsDict([self uniqueIdentifier], shown, Shown);
    if (self.hidden == shown) {
        self.hidden = !shown;
    }
    persistDefaultsState(true);
}
%new
- (BOOL)isHidden {
    return (([conversationsFlagsDict[[self uniqueIdentifier]] unsignedIntegerValue] ?: 0) & Hidden) != 0;
}
%new
- (void)setHidden:(BOOL)hidden {
    updateConversationsFlagsDict([self uniqueIdentifier], hidden, Hidden);
    if (self.shown == hidden) {
        self.shown = !hidden;
    }
    persistDefaultsState(true);
}
%new
- (BOOL)shouldHide {
    return !self.shown && (self.hidden || (shouldHideUnknownSenders && ![self.chat hasKnownParticipants]));
}
%new
- (BOOL)isTagged {
    return (([conversationsFlagsDict[[self uniqueIdentifier]] unsignedIntegerValue] ?: 0) & Tagged) != 0;
}
%new
- (void)setTagged:(BOOL)tagged {
    updateConversationsFlagsDict([self uniqueIdentifier], tagged, Tagged);
    if (!tagged) {
        [conversationsTagDict removeObjectForKey:[self uniqueIdentifier]];
    }
    persistDefaultsState(true);
}
%new
- (BOOL)tagMatchesTag:(IrisConversationTag *)tag {
    return self.tagged && self.tag && tag && [self.tag.uuid isEqual:tag.uuid];
}
%new
- (IrisConversationTag *)tag {
    if (!self.tagged) return nil;
    NSString *uuid = conversationsTagDict[[self uniqueIdentifier]];
    if (!uuid) return nil;
    NSUInteger idx = [tagsArray indexOfObjectPassingTest:^BOOL(IrisConversationTag *obj, NSUInteger idx, BOOL *stop) {
        return [obj.uuid.UUIDString isEqualToString:uuid];
    }];
    if (idx == NSNotFound) {
        self.tagged = false;
        return nil;
    }
    return idx < tagsArray.count ? tagsArray[idx] : nil;
}
%new
- (void)setTag:(IrisConversationTag *)tag {
    self.tagged = (BOOL)tag;
    if (tag) {
        conversationsTagDict[[self uniqueIdentifier]] = tag.uuid.UUIDString;
    }
    persistDefaultsState(true);
}
%end

%hook CKConversationList
- (NSMutableArray *)conversations {
    return filterConversations(%orig, currentFlag, currentTag, true, true);
}
%new
- (NSMutableArray *)conversationsForFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag {
    return filterConversations((NSMutableArray *)[self valueForKey:@"_trackedConversations"], flag, tag, true, false);
}
%new
- (NSMutableArray *)pinnedConversationsForFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag {
    return [[[self conversationsForFlag:flag tag:tag] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CKConversation *evaluatedObject, NSDictionary<NSString *,id> *bindings) {
        return evaluatedObject.pinned;
    }]] mutableCopy];
}
%end

%hook CKConversationListController
- (void)_chatUnreadCountDidChange:(NSNotification *)notification {
    [[self conversationList] conversations];
    return %orig;
}
- (NSArray *)activeConversations {
    return [filterConversations(%orig, currentFlag, currentTag, true, false) copy];
}
- (void)viewDidLoad {
    ckclc = self;

    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIView *container = [UIView new];
    container.translatesAutoresizingMaskIntoConstraints = false;
    [container.widthAnchor constraintEqualToConstant:frame.size.width].active = true;
    [container.heightAnchor constraintEqualToConstant:frame.size.height].active = true;

    IrisMenuButtonDimmingView *dimmingView = [IrisMenuButtonDimmingView new];
    [container addSubview:dimmingView];

    updateMenuButtons();
    menuButton.delegate = dimmingView;
    dimmingView.menuButton = menuButton;
    if (!shouldShowButton) {
        menuButton.alpha = 0;
        menuButton.hidden = true;
    }
    [container addSubview:menuButton];
    menuButton.translatesAutoresizingMaskIntoConstraints = false;
    [menuButton.topAnchor constraintEqualToAnchor:container.topAnchor].active = true;
    [menuButton.leadingAnchor constraintEqualToAnchor:container.leadingAnchor].active = true;
    [menuButton.trailingAnchor constraintEqualToAnchor:container.trailingAnchor].active = true;
    [menuButton.heightAnchor constraintGreaterThanOrEqualToConstant:frame.size.height].active = true;

    bbi = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.leftBarButtonItem = bbi;
    return %orig;
}
- (void)viewDidLayoutSubviews {
    if (!self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = bbi;
    }
    if (!defaultNavigationBarTitle) {
        defaultNavigationBarTitle = self.navigationItem.title;
    }
    self.navigationItem.title = currentTag && currentTag.name ? currentTag.name : defaultNavigationBarTitle;
    return %orig;
}
- (NSMutableArray *)actionsForTranscriptPreviewController:(CKTranscriptPreviewController *)previewController {
    NSMutableArray *actions = %orig;
    UIImage *image = [UIImage systemImageNamed:@"circle.fill"];
    [actions addObject:[_UIAction actionWithTitle:@"Tag" image:image style:0 handler:^(UIAction *action) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Tag" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (IrisConversationTag *tag in tagsArray) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:tag.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                previewController.conversation.tag = tag;
                [self.tableView beginUpdates];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
            UIImage *image = [UIImage systemImageNamed:@"circle.fill"];
            [action setValue:image forKey:@"image"];
            [action setValue:tag.colour forKey:@"_titleTextColor"];
            [action setValue:tag.colour forKey:@"_imageTintColor"];
            [actionSheet addAction:action];
        }
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            previewController.conversation.tag = nil;
            [self.tableView beginUpdates];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.tableView beginUpdates];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }]];
        [self presentViewController:actionSheet animated:true completion:nil];
    }]];
    return actions;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKConversationListStandardCell *cell = (CKConversationListStandardCell *)%orig;
    if (![cell isKindOfClass:%c(CKConversationListStandardCell)]) return cell;
    UIImageView *unreadIndicatorView = [cell valueForKey:@"_unreadIndicatorImageView"];
    CKUIBehavior *uiBehaviour = [%c(CKUIBehavior) sharedBehaviors];
    if (!unreadIndicatorView || !uiBehaviour) return cell;

    if (!unreadIndicatorView.superview) {
        [cell addSubview:unreadIndicatorView];
    }

    bool unread = [cell.conversation hasUnreadMessages];
    bool muted = cell.conversation.muted;
    bool pinned = cell.conversation.pinned;
    bool tagged = cell.conversation.tagged;

    if (muted) {
        unreadIndicatorView.image = unread ? uiBehaviour.unreadDNDImage : uiBehaviour.readDNDImage;
    } else if (pinned) {
        unreadIndicatorView.image = unread ? uiBehaviour.unreadPinnedImage : uiBehaviour.readPinnedImage;
    } else if (unread) {
        unreadIndicatorView.image = uiBehaviour.unreadImage;
    } else {
        unreadIndicatorView.image = nil;
    }
    unreadIndicatorView.image = [unreadIndicatorView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    for (CALayer *layer in unreadIndicatorView.layer.sublayers) {
        if ([layer isKindOfClass:[IrisRoundedBorderLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    if (tagged) {
        CALayer *borderLayer = [IrisRoundedBorderLayer roundedBorderLayerForView:unreadIndicatorView colour:cell.conversation.tag.colour.CGColor];
        [unreadIndicatorView.layer addSublayer:borderLayer];
        unreadIndicatorView.layer.masksToBounds = false;
    }

    NSMutableArray<UIColor *> *colours = [NSMutableArray new];
    if (pinned) {
        [colours addObject:[UIColor systemOrangeColor]];
    }
    if (unread) {
        [colours addObject:[UIColor systemBlueColor]];
    }

    if (colours.count > 0) {
        unreadIndicatorView.tintColor = colours[0];
    }
    if (colours.count > 1) {
        [UIView animateKeyframesWithDuration:colours.count * 0.5 delay:0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
            [colours enumerateObjectsUsingBlock:^(UIColor *obj, NSUInteger idx, BOOL *stop) {
                [UIView addKeyframeWithRelativeStartTime:idx * 0.5 relativeDuration:0.5 animations:^{
                    unreadIndicatorView.tintColor = obj;
                }];
            }];
        } completion:nil];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *pinnedConversations = [NSMutableArray new];
    for (CKConversation *conversation in [self activeConversations]) {
        if (conversation.pinned) {
            [pinnedConversations addObject:conversation];
        }
    }
    CKConversation *mobileConversation = pinnedConversations[sourceIndexPath.row];
    [pinnedConversations removeObject:mobileConversation];
    [pinnedConversations insertObject:mobileConversation atIndex:destinationIndexPath.row];
    for (CKConversation *conversation in pinnedConversations) {
        [pinnedConversationList removeObject:[conversation uniqueIdentifier]];
        [conversation setPinned:true];
    }
    return %orig;
}
%new
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (shouldHideSwipeActions) return nil;
    CKConversationListStandardCell *cell = (CKConversationListStandardCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CKConversation *conversation = cell.conversation;
    CKEntity *recipient = conversation.recipient;
    UIContextualAction *hideUnhideAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:conversation.shouldHide ? @"Unhide" : @"Hide" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        if (conversation.shouldHide) {
            conversation.shown = true;
        } else {
            conversation.hidden = true;
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        completionHandler(true);
    }];
    hideUnhideAction.backgroundColor = [UIColor systemBlueColor];
    NSMutableArray *actions = [NSMutableArray new];
    [actions addObject:hideUnhideAction];
    if (recipient && recipient.cnContact.handles.count != 0) {
        CNContactToggleBlockCallerAction *cnBlockAction = [[%c(CNContactToggleBlockCallerAction) alloc] initWithContact:recipient.cnContact];
        UIContextualAction *blockAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:cnBlockAction.isBlocked ? @"Unblock" : @"Block" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if (cnBlockAction.isBlocked) {
                [cnBlockAction unblock];
            } else {
                [cnBlockAction block];
            }
            completionHandler(true);
        }];
        blockAction.backgroundColor = [UIColor systemRedColor];
        [actions addObject:blockAction];
    }
    return [UISwipeActionsConfiguration configurationWithActions:actions];
}
%new
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (shouldToggleWhenShaken && motion == UIEventSubtypeMotionShake) {
        [self switchFlag:currentFlag == Hidden ? Shown : Hidden tag:nil fromMenuButton:false];
    }
}
%new
- (void)setButtonHidden:(bool)hidden {
    if (!menuButton || menuButton.hidden == hidden) return;
    if (menuButton.hidden) menuButton.hidden = false;
    [UIView animateWithDuration:0.25 animations:^{
        menuButton.alpha = hidden ? 0 : 1;
    } completion:^(BOOL finished) {
        menuButton.hidden = hidden;
    }];
}
%new
- (void)didTapMenuButton:(IrisButtonModel *)buttonModel {
    if (buttonModel.tag == 0 && [buttonModel isKindOfClass:[IrisFlagTagButtonModel class]]) {
        [self switchFlag:((IrisFlagTagButtonModel *)buttonModel).conversationFlag tag:((IrisFlagTagButtonModel *)buttonModel).conversationTag fromMenuButton:true];
    } else if (buttonModel.tag == 1) {
        IrisTagListTableViewController *tableViewController = [IrisTagListTableViewController controllerWithTitle:@"Tags" list:tagsArray defaultList:defaultTagsArray() saveHandler:^(NSMutableArray<IrisConversationTag *> * _Nonnull tags, bool isBeingDismissed) {
            updateTagsArray(tags, !isBeingDismissed, true, true);
        }];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
        [self presentViewController:navigationController animated:true completion:nil];
    }
}
%new
- (void)switchFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag fromMenuButton:(BOOL)fromMenuButton {
    if (shouldSecureHiddenList && !isAuthenticated && flag == Hidden) {
        LAContext *context = [LAContext new];
        NSError *error = nil;
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Iris" reply:^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isAuthenticated = true;
                        [self _switchFlag:flag tag:tag];
                    });
                } else if (fromMenuButton) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [menuButton revertToPreviousButton];
                    });
                }
            }];
        }
    } else {
        [self _switchFlag:flag tag:tag];
    }
}
%new
- (void)_switchFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag {
    currentFlag = flag;
    currentTag = tag;

    if ([[menuButton.buttonModels firstObject] isKindOfClass:[IrisFlagTagButtonModel class]] && (((IrisFlagTagButtonModel *)[menuButton.buttonModels firstObject]).conversationFlag != flag || ![((IrisFlagTagButtonModel *)[menuButton.buttonModels firstObject]).conversationTag.uuid isEqual:tag.uuid])) {
        NSUInteger idx = [((NSArray<IrisFlagTagButtonModel *> *)menuButton.buttonModels) indexOfObjectPassingTest:^BOOL(IrisFlagTagButtonModel *obj, NSUInteger idx, BOOL *stop) {
            return obj.conversationFlag == flag && ((obj.conversationTag && tag && [obj.conversationTag.uuid isEqual:tag.uuid]) || (!obj.conversationTag && !tag));
        }];
        if (idx != NSNotFound) {
            [menuButton reloadCollectionViewWithTopButtonModel:menuButton.buttonModels[idx] animated:true];
        }
    }

    if (shouldShowButtonAfterAuthentication) {
        [self setButtonHidden:false];
    }

    if (!defaultNavigationBarTitle) {
        defaultNavigationBarTitle = self.navigationItem.title;
    }
    self.navigationItem.title = tag && tag.name ? tag.name : defaultNavigationBarTitle;

    [self.tableView beginUpdates];
    if ([self respondsToSelector:@selector(_updateConversationListsAndSortIfEnabled)]) {
        [self _updateConversationListsAndSortIfEnabled];
    } else {
        if ([self respondsToSelector:@selector(_updateFilteredConversationLists)]) {
            [self _updateFilteredConversationLists];
        }
        if ([self respondsToSelector:@selector(_updateNonPlaceholderConverationLists)]) {
            [self _updateNonPlaceholderConverationLists];
        }
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

    persistDefaultsState(false);
}
%end

%hook CKMessagesController
- (BOOL)resumeToConversation:(CKConversation *)conversation {
    if (shouldSecureHiddenList && conversation.shouldHide) {
        return false;
    } 
    return %orig;
}
%end

%hook CKAvatarNavigationBar
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.allSubviews) {
        if (subview.userInteractionEnabled && CGRectContainsPoint(subview.frame, [self convertPoint:point toView:subview]) && [NSStringFromClass([subview class]) containsString:@"Iris"]) {
            return true;
        }
    }
    return %orig;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSArray *allSubviews = self.allSubviews;
    for (int i = allSubviews.count - 1; i >= 0; i--) {
        UIView *view = allSubviews[i];
        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return view;
        }
    }
    return nil;
}
%end

%hook CKAvatarView
- (void)avatarCardControllerWillBeginPreviewInteraction:(id)previewInteraction {
    [ckclc.messagesController.view endEditing:true];
    return %orig;
}
%end

%hook SMSApplication
- (void)applicationWillTerminate {
    persistDefaultsState(true);
    return %orig;
}
%end
%end

%group Messages_QuickSwitch
%hook CKBrowserSwitcherFooterView
- (instancetype)initWithFrame:(CGRect)frame toggleBordersOnInterfaceStyle:(BOOL)toggleBordersOnInterfaceStyle {
    id orig = %orig;
    [[orig collectionView] registerClass:[IrisAvatarCollectionViewCell class] forCellWithReuseIdentifier:@"IrisAvatarCollectionViewCell"];
    return orig;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return %orig + 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [[%c(CKConversationList) sharedConversationList] pinnedConversationsForFlag:Shown tag:nil].count;
    }
    return %orig;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        IrisAvatarCollectionViewCell *cell = (IrisAvatarCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IrisAvatarCollectionViewCell" forIndexPath:indexPath];
        [cell initPostDequeueWithConversation:[[%c(CKConversationList) sharedConversationList] pinnedConversationsForFlag:Shown tag:nil][indexPath.item] tapHandler:^(CKConversation * _Nullable conversation) {
            if (conversation) {
                [ckclc.messagesController showConversation:conversation animate:true userInitiated:true];
            }
        }];
        return cell;
    }
    return %orig;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return false;
    }
    return %orig;
}
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath {
    if (proposedIndexPath.section == 0 || (proposedIndexPath.section == 1 && proposedIndexPath.item < ([%c(CKBalloonPluginManager) sharedInstance].isAppStoreEnabled ? 2 : 1)) || (proposedIndexPath.section == 2 && proposedIndexPath.item > 0)) {
        return originalIndexPath;
    }
    return proposedIndexPath;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != 0 && destinationIndexPath.section != 0) {
        return %orig;
    }
}
%end

%hook CKBrowserSwitcherFooterViewDataSource
- (id)switcherView:(CKBrowserSwitcherFooterView *)switcherView modelAtIndexPath:(NSIndexPath *)indexPath type:(NSInteger *)type {
    return indexPath.section == 0 ? nil : %orig;
}
- (NSIndexPath *)switcherView:(CKBrowserSwitcherFooterView *)switcherView indexPathOfModelWithIdentifier:(NSString *)identifier {
    NSIndexPath *orig = %orig;
    return [NSIndexPath indexPathForItem:orig.item inSection:orig.section + 1];
}
%end

%hook CKAppStripLayout
- (NSUInteger)_itemCount {
    return %orig + [(CKBrowserSwitcherFooterView *)self.collectionView.delegate collectionView:self.collectionView numberOfItemsInSection:0];
}
- (NSMutableArray *)_generateAttributesForSpec:(void *)spec {    
    NSMutableArray<CKAppStripLayoutAttributes *> *orig = %orig;
    NSMutableArray<CKAppStripLayoutAttributes *> *generatedAttributes = [NSMutableArray new];
    for (int idx = 0; idx < [self.collectionView numberOfItemsInSection:0]; idx ++) {
        CKAppStripLayoutAttributes *attributes = [%c(CKAppStripLayoutAttributes) layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
        attributes.size = *(CGSize *)spec;
        attributes.frame = CGRectMake(0, 0, attributes.size.width, attributes.size.height);
        attributes.showsBorder = false;
        attributes.appStripSize = *(NSInteger *)(spec + 0x30);
        [generatedAttributes addObject:attributes];
    }
    [generatedAttributes addObjectsFromArray:orig];
    CGFloat spacing = *(CGFloat *)(spec + 0x28) + (*(CGSize *)spec).width;
    CGFloat currentX = 0;
    for (int idx = 0; idx < generatedAttributes.count; idx++) {
        CKAppStripLayoutAttributes *attributes = generatedAttributes[idx];
        attributes.frame = CGRectMake(currentX, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
        currentX += spacing;
    }
    return generatedAttributes;
}
- (NSMutableArray *)_generateSupplementryAttributesForSpec:(void *)spec minified:(BOOL)minified {
    NSMutableArray<CKAppStripLayoutAttributes *> *currentAttributes = [self valueForKey:minified ? @"_minifiedAttributes" : @"_magnifiedAttributes"];
    NSMutableArray<UICollectionViewLayoutAttributes *> *generatedAttributes = [NSMutableArray new];
    NSInteger idxTotal = -1;
    for (int idx = 0; idx < self.collectionView.numberOfSections; idx++) {
        idxTotal += [self.collectionView numberOfItemsInSection:idx];
        if (idxTotal > 0 && idxTotal < currentAttributes.count - 1) {
            CKAppStripLayoutAttributes *attributesA = currentAttributes[idxTotal];
            CKAppStripLayoutAttributes *attributesB = currentAttributes[idxTotal + 1];
            UICollectionViewLayoutAttributes *supplementaryAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[%c(CKBrowserSwitcherFooterAccessoryCell) supplementryViewKind] withIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
            supplementaryAttributes.size = *(CGSize *)(spec + 0x10);
            CGFloat maxX = CGRectGetMaxX(attributesA.frame);
            CGFloat minX = CGRectGetMinX(attributesB.frame);
            CGFloat x = round((minX + (maxX - minX) / 2) * UIScreen.mainScreen.scale) / UIScreen.mainScreen.scale;
            supplementaryAttributes.frame = CGRectMake(x, 0, supplementaryAttributes.size.width, supplementaryAttributes.size.height);
            [generatedAttributes addObject:supplementaryAttributes];
        }
    }
    return generatedAttributes;
}
- (CKAppStripLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idxTotal = indexPath.item;
    for (int idx = 0; idx < indexPath.section; idx++) {
        idxTotal += [self.collectionView numberOfItemsInSection:idx];
    }
    NSMutableArray *currentAttributes = [self _currentAttributes];
    return idxTotal < currentAttributes.count ? currentAttributes[idxTotal] : nil;
}
- (CKAppStripLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position {
    NSInteger idxTotal = indexPath.item;
    for (int idx = 0; idx < indexPath.section; idx++) {
        idxTotal += [self.collectionView numberOfItemsInSection:idx];
    }
    NSMutableArray *currentAttributes = [self _currentAttributes];
    CKAppStripLayoutAttributes *attributes = [idxTotal < currentAttributes.count ? currentAttributes[idxTotal] : nil copy];
    attributes.center = position;
    return attributes;
}
- (CKAppStripLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idxTotal = indexPath.item;
    for (int idx = 0; idx < indexPath.section; idx++) {
        idxTotal += [self.collectionView numberOfItemsInSection:idx];
    }
    NSMutableArray *currentAttributes = [self _currentAttributes];
    return idxTotal < currentAttributes.count ? currentAttributes[idxTotal] : nil;
}
- (CKAppStripLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idxTotal = indexPath.item;
    for (int idx = 0; idx < indexPath.section; idx++) {
        idxTotal += [self.collectionView numberOfItemsInSection:idx];
    }
    NSMutableArray *currentAttributes = [[self valueForKey:@"_inLayoutModeTransition"] boolValue] ? [self _attributesForLayoutMode:self.layoutMode] : [self _currentAttributes];
    return idxTotal < currentAttributes.count ? currentAttributes[idxTotal] : nil;
}
%end

%hook CKAppManagerViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return %orig + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 0 : %orig;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section == 0 ? [UIView new] : %orig;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? false : %orig;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != 0 && destinationIndexPath.section != 0) {
        return %orig;
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath {
    if (proposedIndexPath.section == 0) {
        return originalIndexPath;
    }
    return %orig;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return %orig;
    }
}
%end

%hook CKBalloonPluginManager
- (NSMutableDictionary *)_decodeIndexPathMap:(NSMutableDictionary *)indexPathMap {
    NSMutableDictionary<NSString *, NSIndexPath *> *orig = %orig;
    __block bool needsMigration = false;
    for (NSString *key in orig) {
        if (orig[key].section == 0) {
            needsMigration = true;
            break;
        }
    }
    NSMutableDictionary *migratedDictionary = [NSMutableDictionary new];
    if (needsMigration) {
        for (NSString *key in orig) {
            NSIndexPath *indexPath = orig[key];
            migratedDictionary[key] = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section + 1];
        }
    } else {
        migratedDictionary = orig;
    }
    return migratedDictionary;
}
%end
%end

// IMAgent Hooks

%group IMAgent
%hook IMDBadgeUtilities
- (instancetype)init {
    id orig = %orig;
    imdbu = orig;
    return orig;
}
- (void)updateBadgeForUnreadCountChangeIfNeeded:(long long)count {
    return shouldHideHiddenUnreadCountFromSBBadge ? %orig(shownUnreadCount) : %orig;
}
%end
%end

// TCCd Hooks

%group TCCd
%hook TCCDService
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list {
    if ([self.name isEqual:@"kTCCServiceFaceID"]) {
        NSMutableArray *mutableList = [list mutableCopy];
        [mutableList addObject:@"com.apple.MobileSMS"];
        return %orig([mutableList copy]);
    }
    return %orig;
}
%end
%end

// SpringBoard Hooks

%group SpringBoard
%hook SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)event {
    if (shouldToggleWhenVolumePressedSimultaneously) {
        bool containsVolumeUp = false;
        bool containsVolumeDown = false;
        for (UIPress *press in event.allPresses) {
            if (press.force == 1) {
                if (!containsVolumeUp) containsVolumeUp = press.type == 102;
                if (!containsVolumeDown) containsVolumeDown = press.type == 103;
            }
        }
        if (containsVolumeUp && containsVolumeDown) {
            [notificationCentre postNotificationWithName:toggleHiddenListNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
        }
    }
    return %orig;
}
- (void)_ringerChanged:(void *)event {
    if (shouldToggleWhenRingerSwitched) {
        if (lastRingerSwitch && [lastRingerSwitch timeIntervalSinceNow] > -2) ringerSwitchedCount++;
        else ringerSwitchedCount = 1;
        lastRingerSwitch = [NSDate date];
        if (shouldToggleWhenRingerSwitched && ringerSwitchedCount == 3) {
            ringerSwitchedCount = 0;
            [notificationCentre postNotificationWithName:toggleHiddenListNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
        }
    }
    return %orig;
}
%end
%end

// Constructor

%ctor {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.jacobcxdev.iris.plist"];
    if (settings) {
        bool enabled = ![settings objectForKey:@"enabled"] || [[settings objectForKey:@"enabled"] boolValue];
        if (!enabled) return;
        shouldShowButton = ![settings objectForKey:shouldShowButtonKey] || [[settings objectForKey:shouldShowButtonKey] boolValue];
        shouldToggleWhenShaken = [settings objectForKey:shouldToggleWhenShakenKey] && [[settings objectForKey:shouldToggleWhenShakenKey] boolValue];
        shouldToggleWhenVolumePressedSimultaneously = [settings objectForKey:shouldToggleWhenVolumePressedSimultaneouslyKey] && [[settings objectForKey:shouldToggleWhenVolumePressedSimultaneouslyKey] boolValue];
        shouldToggleWhenRingerSwitched = [settings objectForKey:shouldToggleWhenRingerSwitchedKey] && [[settings objectForKey:shouldToggleWhenRingerSwitchedKey] boolValue];
        shouldHideUnknownSenders = [settings objectForKey:shouldHideUnknownSendersKey] && [[settings objectForKey:shouldHideUnknownSendersKey] boolValue];
        shouldHideHiddenUnreadCountFromSBBadge = [settings objectForKey:shouldHideHiddenUnreadCountFromSBBadgeKey] && [[settings objectForKey:shouldHideHiddenUnreadCountFromSBBadgeKey] boolValue];
        shouldHideButtonBadge = [settings objectForKey:shouldHideButtonBadgeKey] && [[settings objectForKey:shouldHideButtonBadgeKey] boolValue];
        shouldSecureHiddenList = [settings objectForKey:shouldSecureHiddenListKey] && [[settings objectForKey:shouldSecureHiddenListKey] boolValue];
        shouldShowButtonAfterAuthentication = [settings objectForKey:shouldShowButtonAfterAuthenticationKey] && [[settings objectForKey:shouldShowButtonAfterAuthenticationKey] boolValue];
        shouldAutoHideHiddenList = [settings objectForKey:shouldAutoHideHiddenListKey] && [[settings objectForKey:shouldAutoHideHiddenListKey] boolValue];
        shouldHideSwipeActions = [settings objectForKey:shouldHideSwipeActionsKey] && [[settings objectForKey:shouldHideSwipeActionsKey] boolValue];
        isQuickSwitchEnabled = ![settings objectForKey:isQuickSwitchEnabledKey] || [[settings objectForKey:isQuickSwitchEnabledKey] boolValue];
    }

    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.tccd"]) {
        %init(TCCd);
    } else {
        notificationCentre = [JCXNotificationCentre centre];
        NSString *mainBundleID = [NSBundle mainBundle].bundleIdentifier;
        if ([mainBundleID isEqualToString:@"com.apple.MobileSMS"]) {
            userDefaults = [NSUserDefaults standardUserDefaults];
            actionManager = [%c(CKSpringBoardActionManager) new];
            notificationCentre.postHandler = ^NSDictionary *(NSString *name) {
                if ([name isEqualToString:localUpdateNotificationName]) {
                    return @{
                        shouldHideHiddenUnreadCountFromSBBadgeKey: @(shouldHideHiddenUnreadCountFromSBBadge),
                        shownUnreadCountKey: @(shownUnreadCount)
                    };
                }
                return nil;
            };
            notificationCentre.receivedHandler = ^(NSNotification *notification) {
                if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
                    if (blurWindow && !blurWindow.hidden) {
                        [UIView animateWithDuration:0.25 animations:^{
                            blurWindow.alpha = 0;
                        } completion:^(BOOL finished){
                            blurWindow.hidden = true;
                        }];
                    }
                } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
                    if (ckclc) {
                        [ckclc.tableView reloadData];
                        if (shouldHideCurrentConversation) {
                            shouldHideCurrentConversation = false;
                            [ckclc.messagesController showConversationList:true];
                        }
                    }
                    if (!shouldShowButton) {
                        [ckclc setButtonHidden:true];
                    }
                } else if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
                    if ((shouldSecureHiddenList || shouldAutoHideHiddenList) && currentFlag == Hidden) {
                        if (!blurWindow) {
                            UIWindowScene *scene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes.allObjects firstObject];
                            if (!scene) return;
                            blurWindow = [[UIWindow alloc] initWithWindowScene:scene];
                            blurWindow.frame = UIScreen.mainScreen.bounds;
                            blurWindow.windowLevel = UIWindowLevelAlert;
                            blurWindow.alpha = 0;
                            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]];
                            blurEffectView.frame = blurWindow.frame;
                            [blurWindow addSubview:blurEffectView];
                        }
                        blurWindow.hidden = false;
                        [UIView animateWithDuration:0.25 animations:^{
                            blurWindow.alpha = 1;
                        }];
                        [blurWindow makeKeyAndVisible];
                    }
                } else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
                    isAuthenticated = false;
                    if (shouldAutoHideHiddenList && currentFlag == Hidden) {
                        shouldHideCurrentConversation = true;
                        [ckclc _switchFlag:Shown tag:nil];
                    }
                    if (currentFlag != Hidden) {
                        [actionManager updateShortcutItems];
                    }
                } else if ([notification.name isEqualToString:toggleHiddenListNotificationName]) {
                    if (ckclc && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                        [ckclc switchFlag:currentFlag == Hidden ? Shown : Hidden tag:nil fromMenuButton:false];
                    }
                } else if ([notification.name isEqualToString:localRequestNotificationName]) {
                    [notificationCentre postNotificationUsingPostHandlerWithName:localUpdateNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
                } else if ([notification.name isEqualToString:userDefaultsDidUpdateNotificationName]) {
                    restoreDefaultsState(true, true);
                    [ckclc updateConversationList];
                }
            };
            [notificationCentre observeNotificationsWithName:UIApplicationDidBecomeActiveNotification from:[NSNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:UIApplicationWillEnterForegroundNotification from:[NSNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:UIApplicationWillResignActiveNotification from:[NSNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:UIApplicationDidEnterBackgroundNotification from:[NSNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:toggleHiddenListNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:localRequestNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:userDefaultsDidUpdateNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre postNotificationWithName:iCloudRestoreNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
            %init(Messages);
            if (isQuickSwitchEnabled) {
                void *handle = dlopen("/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", RTLD_NOW);
                if (handle) {
                    MSHookMemory = (MSHookMemory_t)(dlsym(handle, "MSHookMemory"));
                    favouritesSectionSym = MSFindSymbol(MSGetImageByName("/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit"), "_CKAppStripFavoritesSection");
                    recentsSectionSym = MSFindSymbol(MSGetImageByName("/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit"), "_CKAppStripRecentsSection");
                    const NSInteger favouritesSection = 1;
                    const NSInteger recentsSection = 2;
                    MSHookMemory(favouritesSectionSym, &favouritesSection, sizeof(NSInteger));
                    MSHookMemory(recentsSectionSym, &recentsSection, sizeof(NSInteger));
                    dlclose(handle);
                }
                %init(Messages_QuickSwitch);
            }
#ifdef MOCKUP
            %init(Mockup);
#endif
        } else if ([mainBundleID isEqualToString:@"com.apple.imagent"]) {
            userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.MobileSMS"];
            notificationCentre.receivedHandler = ^(NSNotification *notification) {
                if ([notification.name isEqualToString:localUpdateNotificationName]) {
                    shouldHideHiddenUnreadCountFromSBBadge = [notification.userInfo objectForKey:shouldHideHiddenUnreadCountFromSBBadgeKey] && [[notification.userInfo objectForKey:shouldHideHiddenUnreadCountFromSBBadgeKey] boolValue];
                    shownUnreadCount = [notification.userInfo objectForKey:shownUnreadCountKey] ? [[notification.userInfo objectForKey:shownUnreadCountKey] intValue] : [userDefaults integerForKey:shownUnreadCountKey];
                    hiddenUnreadCount = [notification.userInfo objectForKey:hiddenUnreadCountKey] ? [[notification.userInfo objectForKey:hiddenUnreadCountKey] intValue] : [userDefaults integerForKey:hiddenUnreadCountKey];
                    [imdbu updateBadgeForUnreadCountChangeIfNeeded:shownUnreadCount + hiddenUnreadCount];
                }
            };
            [notificationCentre observeNotificationsWithName:localUpdateNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre postNotificationWithName:localRequestNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
            %init(IMAgent);
        } else if ([mainBundleID isEqualToString:@"com.apple.springboard"]) {
            userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.MobileSMS"];
            store = [NSUbiquitousKeyValueStore defaultStore];
            notificationCentre.receivedHandler = ^(NSNotification *notification) {
                if ([notification.name isEqualToString:iCloudPersistNotificationName]) {
                    restoreDefaultsState(true, false);
                    persistiCloudState();
                } else if ([notification.name isEqualToString:iCloudRestoreNotificationName] || [notification.name isEqualToString:NSUbiquitousKeyValueStoreDidChangeExternallyNotification]) {
                    restoreiCloudState(true, false);
                    persistDefaultsState(false);
                    [notificationCentre postNotificationWithName:userDefaultsDidUpdateNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
                }
            };
            [notificationCentre observeNotificationsWithName:iCloudPersistNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:iCloudRestoreNotificationName from:[NSDistributedNotificationCenter defaultCenter]];
            [notificationCentre observeNotificationsWithName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:store from:[NSNotificationCenter defaultCenter]];
            %init(SpringBoard);
        } else return;

        restoreDefaultsState(true, false);
        [imdbu updateBadgeForUnreadCountChangeIfNeeded:shownUnreadCount + hiddenUnreadCount];
    }

    NSLog(@"Iris loaded");
}