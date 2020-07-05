#import "IrisFlagTagSelectionViewController.h"
#import <libJCX/Utilities.h>
#import "src/Objective-C/Globals.h"

@implementation IrisFlagTagSelectionViewController
+ (instancetype _Nonnull)controllerWithTitle:(NSString * _Nullable)title defaults:(NSString * _Nonnull)defaults {
    return [[self alloc] initWithTitle:title defaults:defaults];
}
- (instancetype _Nonnull)initWithTitle:(NSString * _Nullable)title defaults:(NSString * _Nonnull)defaults {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _navBarTitle = title;
        _defaults = defaults;
        [self loadList];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _navBarTitle;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveList];
}
- (void)loadList {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:_defaults];
    NSData *tagsArrayData = [userDefaults dataForKey:tagsArrayKey];
    NSMutableArray *tagsArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[NSMutableArray class], [IrisConversationTag class], [NSUUID class], [NSString class], [UIColor class]]] fromData:tagsArrayData error:nil];
    _list = tagsArray ? generateButtonModelsWithTags(tagsArray, false, false) : [NSMutableArray new];
    _selectedFlag = [userDefaults objectForKey:defaultFlagKey] ? [[userDefaults objectForKey:defaultFlagKey] unsignedIntegerValue] : Shown;
    _selectedTagUUID = [userDefaults stringForKey:defaultTagUUIDKey];
}
- (void)saveList {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:_defaults];
    [userDefaults setObject:@(_selectedFlag) forKey:defaultFlagKey];
    [userDefaults setObject:_selectedTagUUID forKey:defaultTagUUIDKey];
    [[JCXNotificationCentre centre] postNotificationWithName:userDefaultsDidUpdateNotificationName to:[NSDistributedNotificationCenter defaultCenter]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"entryCell"];
    IrisFlagTagButtonModel *buttonModel = _list[indexPath.row];
    cell.textLabel.text = buttonModel.name;
    cell.imageView.image = buttonModel.image;
    cell.imageView.tintColor = buttonModel.tintColour;
    cell.accessoryType = buttonModel.conversationFlag == _selectedFlag && ((!buttonModel.conversationTag && !_selectedTagUUID) || [buttonModel.conversationTag.uuid.UUIDString isEqualToString:_selectedTagUUID]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    IrisFlagTagButtonModel *buttonModel = _list[indexPath.row];
    _selectedFlag = buttonModel.conversationFlag;
    _selectedTagUUID = buttonModel.conversationTag.uuid.UUIDString;
    [tableView reloadData];
    [self saveList];
}
@end