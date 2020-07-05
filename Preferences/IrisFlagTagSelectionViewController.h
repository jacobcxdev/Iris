#import <UIKit/UIKit.h>
#import "IrisPreferences-Swift.h"

@interface IrisFlagTagSelectionViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) NSMutableArray<IrisFlagTagButtonModel *> * _Nonnull list;
@property (nonatomic, retain) NSString * _Nonnull defaults;
@property (nonatomic, retain) NSString * _Nullable navBarTitle;
@property (nonatomic, retain) NSString * _Nullable selectedTagUUID;
@property (nonatomic) IrisConversationFlag selectedFlag;
+ (instancetype _Nonnull)controllerWithTitle:(NSString * _Nullable)title defaults:(NSString * _Nonnull)defaults;
- (instancetype _Nonnull)initWithTitle:(NSString * _Nullable)title defaults:(NSString * _Nonnull)defaults;
- (void)loadList;
- (void)saveList;
@end