//
//  Tweak.h
//  Iris
//
//  Created by Jacob Clayden on 05/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Iris-Swift.h"

// Messages Interfaces

@interface _UIAction : NSObject
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(long long)style handler:(UIActionHandler)handler;
@end

@interface IMChat : NSObject
@property (nonatomic, strong, readwrite) NSString *displayName;
- (BOOL)hasKnownParticipants;
@end

@interface IMChatRegistry : NSObject
- (IMChat *)existingChatWithGUID:(id)guid;
@end

@interface CNContact : NSObject
@property (readonly) NSArray *handles;
@end

@interface CNUIPRLikenessLookup : NSObject
- (id)photoFutureForContactFuture:(id)contactFuture scheduler:(id)scheduler;
- (id)photoFutureForContactFuture:(id)contactFuture photoFuture:(id)photoFuture allowingFallbackForMeCard:(bool)allowingFallbackForMeCard;
- (id)blessedPhotoObservableWithFuture:(id)photoFuture contact:(CNContact *)contact workScheduler:(id)workScheduler;
@end

@interface CKEntity : NSObject
@property (nonatomic, strong, readwrite) CNContact *cnContact;
@end

@interface CKConversation : NSObject
@property (nonatomic, strong, readwrite) IMChat *chat;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readwrite) NSString *displayName;
@property (nonatomic, copy, readwrite) NSString *previewText;
@property (nonatomic, strong, readwrite) NSNumber *businessConversation;
@property (nonatomic, readonly) BOOL hasDisplayName;
@property (nonatomic, readonly) BOOL hasUnreadMessages;
@property (nonatomic, readonly) NSUInteger unreadCount;
@property (nonatomic, readonly) CKEntity *recipient;
@property (nonatomic, readonly) NSUInteger recipientCount;
@property (nonatomic, readwrite, getter=isShown) BOOL shown;
@property (nonatomic, readwrite, getter=isHidden) BOOL hidden;
@property (nonatomic, readwrite, getter=isTagged) BOOL tagged;
@property (nonatomic, readwrite, getter=isPinned) BOOL pinned;
@property (nonatomic, readonly, getter=isMuted) BOOL muted;
@property (nonatomic, readonly) BOOL shouldHide;
@property (nonatomic, readwrite) IrisConversationTag *tag;
+ (BOOL)pinnedConversationsEnabled;
- (NSArray *)orderedContactsWithMaxCount:(NSUInteger)maxCount keysToFetch:(NSArray *)keysToFetch;
- (NSNumber *)pinnedIndex;
- (void)setMutedUntilDate:(NSDate *)date;
- (BOOL)tagMatchesTag:(IrisConversationTag *)tag;
- (NSString *)uniqueIdentifier;
- (void)unmute;
@end

@interface CKConversationList : NSObject
+ (instancetype)sharedConversationList;
- (CKConversation *)_conversationForChat:(IMChat *)chat;
- (NSMutableArray *)conversations;
- (NSMutableArray *)conversationsForFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag;
- (NSMutableArray *)pinnedConversationsForFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag;
- (NSMutableArray *)recentConversationsForFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag;
@end

@interface CKConversationListStandardCell : UITableViewCell {
    UIImageView *_unreadIndicatorImageView;
}
@property (nonatomic, strong, readwrite) CKConversation *conversation;
@end

@interface CKTranscriptPreviewController : NSObject
@property (nonatomic, strong, readwrite) CKConversation *conversation;
@end

@interface CKUIBehavior : NSObject
@property (nonatomic, readonly) UIFont *browserCellFont;
@property (nonatomic, readonly) UIImage *unreadImage;
@property (nonatomic, readonly) UIImage *readDNDImage;
@property (nonatomic, readonly) UIImage *unreadDNDImage;
@property (nonatomic, readonly) UIImage *readPinnedImage;
@property (nonatomic, readonly) UIImage *unreadPinnedImage;
+ (instancetype)sharedBehaviors;
- (BOOL)contactPhotosEnabled;
@end

@interface CKMessagesController : UIViewController
- (NSMutableArray *)actionsForTranscriptPreviewController:(CKTranscriptPreviewController *)previewController;
- (BOOL)resumeToConversation:(CKConversation *)conversation;
- (void)showConversation:(CKConversation *)conversation animate:(BOOL)animate userInitiated:(BOOL)userInitiated;
- (void)showConversationList:(BOOL)clearChatControllers;
@end

@interface CKConversationListController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak, readwrite) CKMessagesController *messagesController;
- (void)_chatUnreadCountDidChange:(NSNotification *)notification;
- (void)_conversationListDidChange:(NSNotification *)notification;
- (void)_updateConversationListsAndSortIfEnabled;
- (void)_updateFilteredConversationLists;
- (void)_updateNonPlaceholderConverationLists;
- (void)_switchFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag;
- (NSArray *)activeConversations;
- (CKConversationList *)conversationList;
- (void)didTapMenuButton:(IrisButtonModel *)buttonModel;
- (void)setButtonHidden:(bool)hidden;
- (void)switchFlag:(IrisConversationFlag)flag tag:(IrisConversationTag *)tag fromMenuButton:(BOOL)fromMenuButton;
- (void)updateConversationList;
@end

@interface CNContactToggleBlockCallerAction : NSObject
@property (nonatomic, readonly) BOOL isBlocked;
- (void)block;
- (void)unblock;
- (instancetype)initWithContact:(CNContact *)contact;
@end

@interface CKAvatarNavigationBar : UINavigationBar
@end

@interface CKBrowserSwitcherFooterView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>
- (instancetype)initWithFrame:(CGRect)frame toggleBordersOnInterfaceStyle:(BOOL)toggleBordersOnInterfaceStyle;
- (UICollectionView *)collectionView;
- (void)reloadData;
- (void)selectPluginAtIndexPath:(NSIndexPath *)indexPath; 
@end

@interface CKBrowserSwitcherFooterAccessoryCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
+ (id)supplementryViewKind;
@end

@interface CKAppStripLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, readwrite) NSInteger appStripSize;
@property (nonatomic, readwrite) BOOL showsBorder;
@end

@interface CKAppStripLayout : UICollectionViewLayout
@property (nonatomic, readwrite) NSUInteger layoutMode;
- (NSMutableArray *)_attributesForLayoutMode:(NSUInteger)layoutMode;
- (NSMutableArray *)_currentAttributes;
- (NSInteger)_itemCount;
- (NSInteger)_favoritesCount;
- (NSMutableArray *)_generateAttributesForSpec:(void *)spec;
- (NSMutableArray *)_generateSupplementryAttributesForSpec:(void *)spec minified:(BOOL)minified;
- (NSInteger)_recentsCount;
- (CKAppStripLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CKAppStripLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position;
- (CKAppStripLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath;
- (CKAppStripLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface CKBrowserSwitcherFooterViewDataSource
- (id)switcherView:(CKBrowserSwitcherFooterView *)switcherView modelAtIndexPath:(NSIndexPath *)indexPath type:(NSInteger *)type;
- (NSIndexPath *)switcherView:(CKBrowserSwitcherFooterView *)switcherView indexPathOfModelWithIdentifier:(NSString *)identifier;
@end

@interface CKAppManagerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@end

@interface CKBalloonPluginManager : NSObject
@property (nonatomic, readonly) BOOL isAppStoreEnabled;
+ (CKBalloonPluginManager *)sharedInstance;
- (NSMutableDictionary *)_decodeIndexPathMap:(NSMutableDictionary *)indexPathMap;
@end

@interface CNAvatarView : UIView
@property (nonatomic, readwrite) BOOL asynchronousRendering;
@property (nonatomic, readwrite) BOOL bypassActionValidation;
@property (nonatomic, readwrite) BOOL showsContactOnTap;
@property (nonatomic, weak, readwrite) UIViewController *presentingViewController;
@property (nonatomic, copy, readwrite) NSArray *actionCategories;
@property (nonatomic, strong, readwrite) CNContact *contact;
@property (nonatomic, strong, readwrite) NSArray *contacts;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) NSUInteger style;
@property (nonatomic, copy, readwrite) UIImageView *imageView;
@end

@protocol CNAvatarViewDelegate<NSObject>
- (UIViewController *)presentingViewControllerForAvatarView:(CNAvatarView *)avatarView;
@end

@interface CKAvatarView : CNAvatarView
@property (nonatomic, weak, readwrite) NSObject<CNAvatarViewDelegate> *delegate;
@end

@interface CKSpringBoardActionManager : NSObject
- (void)updateShortcutItems;
@end

@interface SMSApplication : UIApplication<UIApplicationDelegate>
- (void)applicationWillTerminate;
@end

// IMAgent Interfaces

@interface IMDBadgeUtilities : NSObject
- (void)updateBadgeForUnreadCountChangeIfNeeded:(long long)count;
@end

// TCCd Interfaces

@interface TCCDService : NSObject
@property (retain, nonatomic) NSString *name;
- (void)setDefaultAllowedIdentifiersList:(NSArray *)list;
@end

// SpringBoard Interfaces

@interface SpringBoard : NSObject
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)event;
- (void)_ringerChanged:(void *)event;
@end