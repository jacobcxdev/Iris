#import <UIKit/UIKit.h>
#import "../Tweak/Tweak.h"

@interface IrisAvatarCollectionViewCell : UICollectionViewCell<CNAvatarViewDelegate>
@property (nonatomic, readonly) CKAvatarView * _Nullable avatarView;
@property (nonatomic, readonly) CKConversation * _Nullable conversation;
@property (nonatomic, readonly) UIStackView * _Nullable stackView;
@property (nonatomic, copy) void (^ _Nullable tapHandler)(CKConversation * _Nullable);
- (void)initPostDequeueWithConversation:(CKConversation * _Nullable)conversation tapHandler:(void (^ _Nullable)(CKConversation * _Nullable))tapHandler;
- (void)setupAvatarView;
- (void)setupStackView;
- (UIImageView * _Nullable)browserImage;
@end