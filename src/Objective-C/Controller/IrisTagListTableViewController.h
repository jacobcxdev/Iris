#import <UIKit/UIKit.h>
#import "../Model/IrisConversationTag.h"

@interface IrisTagListTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) NSMutableArray<IrisConversationTag *> * _Nonnull list;
@property (nonatomic, retain) NSArray<IrisConversationTag *> * _Nullable defaultList;
@property (nonatomic, retain) NSString * _Nullable navBarTitle;
@property (nonatomic, copy) void (^ _Nonnull saveHandler)(NSMutableArray<IrisConversationTag *> * _Nonnull, bool isBeingDismissed);
+ (instancetype _Nonnull)controllerWithTitle:(NSString * _Nullable)title list:(NSMutableArray<IrisConversationTag *> * _Nonnull)list defaultList:(NSArray<IrisConversationTag *> * _Nullable)defaultList saveHandler:(void (^ _Nonnull)(NSMutableArray<IrisConversationTag *> * _Nonnull, bool isBeingDismissed))saveHandler;
- (instancetype _Nonnull)initWithTitle:(NSString * _Nullable)title list:(NSMutableArray<IrisConversationTag *> * _Nonnull)list defaultList:(NSArray<IrisConversationTag *> * _Nullable)defaultList saveHandler:(void (^ _Nonnull)(NSMutableArray<IrisConversationTag *> * _Nonnull, bool isBeingDismissed))saveHandler;
- (void)addListEntry;
- (void)done;
- (void)edit;
- (void)editListEntryAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)removeListEntryAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)saveList:(bool)isBeingDismissed;
@end