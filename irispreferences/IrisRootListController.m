#import "IrisRootListController.h"

@implementation IrisRootListController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(killall)];
    self.navigationItem.rightBarButtonItem = button;
}
- (void)killall {
    NSTask *killallIMAgent = [NSTask new];
    [killallIMAgent setLaunchPath:@"/usr/bin/killall"];
    [killallIMAgent setArguments:@[@"-9", @"imagent"]];
    [killallIMAgent launch];
    NSTask *killallTCCd = [NSTask new];
    [killallTCCd setLaunchPath:@"/usr/bin/killall"];
    [killallTCCd setArguments:@[@"-9", @"tccd"]];
    [killallTCCd launch];
    NSTask *killallSpringBoard = [NSTask new];
    [killallSpringBoard setLaunchPath:@"/usr/bin/killall"];
    [killallSpringBoard setArguments:@[@"-9", @"SpringBoard"]];
    [killallSpringBoard launch];
}
@end
