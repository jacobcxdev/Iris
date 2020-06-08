#import "IrisTagListTableViewController.h"
#import <libJCX/Utilities.h>
#import "IrisTagCreationAlertController.h"

@implementation IrisTagListTableViewController

+ (instancetype _Nonnull)controllerWithTitle:(NSString * _Nullable)title list:(NSMutableArray<IrisConversationTag *> * _Nonnull)list defaultList:(NSArray<IrisConversationTag *> * _Nullable)defaultList saveHandler:(void (^ _Nonnull)(NSMutableArray<IrisConversationTag *> * _Nonnull, bool isBeingDismissed))saveHandler {
    return [[self alloc] initWithTitle:title list:list defaultList:defaultList saveHandler:saveHandler];
}

- (instancetype _Nonnull)initWithTitle:(NSString * _Nullable)title list:(NSMutableArray<IrisConversationTag *> * _Nonnull)list defaultList:(NSArray<IrisConversationTag *> * _Nullable)defaultList saveHandler:(void (^ _Nonnull)(NSMutableArray<IrisConversationTag *> * _Nonnull, bool isBeingDismissed))saveHandler {
    self = [super initWithStyle:UITableViewStyleGrouped];
    _navBarTitle = title;
    _list = list;
    _defaultList = defaultList;
    _saveHandler = saveHandler;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _navBarTitle;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    if (!_defaultList || _defaultList.count == 0) {
        self.navigationItem.rightBarButtonItems = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetEntries)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addListEntry)]
        ];
    } else {
        self.navigationItem.rightBarButtonItems = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetEntries)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetDefaultEntries)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addListEntry)]
        ];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveList:true];
}

- (void)addListEntry {
    IrisTagCreationAlertController *alert = [IrisTagCreationAlertController alertControllerWithTitle:@"Create Tag" message:@"\nPlease choose the colour and name of the tag you would like to create." preferredStyle:UIAlertControllerStyleAlert];
    __weak IrisTagCreationAlertController *_alert = alert;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = _alert.selectedTag.name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self->_list addObject:alert.selectedTag];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self->_list.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveList:false];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)done {
    [self setEditing:false animated:true];
    [self saveList:false];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
}

- (void)edit {
    [self setEditing:true animated:true];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
}

- (void)editListEntryAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    IrisTagCreationAlertController *alert = [IrisTagCreationAlertController alertControllerWithTitle:@"Edit Tag" message:@"\nPlease choose the colour and name of the tag you would like to edit." preferredStyle:UIAlertControllerStyleAlert];
    alert.originalTag = _list[indexPath.row];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = _list[indexPath.row].name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_list[indexPath.row].name = alert.selectedTag.name;
        self->_list[indexPath.row].colour = alert.selectedTag.colour;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveList:false];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)removeListEntryAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    [_list removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveList:false];
}

- (void)resetDefaultEntries {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset list to defaults?" message:@"\nNB: This will RESET ALL tags.\n" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView beginUpdates];
        for (int idx = 0; idx < self->_list.count; idx++) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }
        self->_list = [NSMutableArray arrayWithArray:_defaultList];
        for (int idx = 0; idx < self->_list.count; idx++) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [self.tableView endUpdates];
        [self saveList:false];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)resetEntries {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset list completely?" message:@"\nNB: This will REMOVE ALL tags.\n" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView beginUpdates];
        for (int idx = 0; idx < self->_list.count; idx++) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self->_list removeAllObjects];
        [self.tableView endUpdates];
        [self saveList:false];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)saveList:(bool)isBeingDismissed {
    _saveHandler(_list, isBeingDismissed);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"entryCell"];
    cell.textLabel.text = _list[indexPath.row].name;
    cell.imageView.image = [UIImage systemImageNamed:@"circle.fill"];
    cell.imageView.tintColor = _list[indexPath.row].colour;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self editListEntryAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeListEntryAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    IrisConversationTag *mobileTag = _list[sourceIndexPath.row];
    [tableView beginUpdates];
    [_list removeObjectAtIndex:sourceIndexPath.row];
    [_list insertObject:mobileTag atIndex:destinationIndexPath.row];
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    [tableView endUpdates];
    [self saveList:false];
}
@end