#import "IrisAvatarCollectionViewCell.h"

@implementation IrisAvatarCollectionViewCell
- (void)initPostDequeueWithConversation:(CKConversation * _Nullable)conversation tapHandler:(void (^ _Nullable)(CKConversation * _Nullable))tapHandler {
    _conversation = conversation;
    _tapHandler = tapHandler;
    if (conversation && [[%c(CKUIBehavior) sharedBehaviors] contactPhotosEnabled]) {
        if (!_stackView) {
            [self setupStackView];
        }
        if (!_avatarView) {
            [self setupAvatarView];
        }
        if (conversation.recipientCount == 1) {
            if (conversation.recipient.cnContact) {
                _avatarView.contact = conversation.recipient.cnContact;
            }
            _avatarView.actionCategories = @[@"audio-call", @"video-call", @"instant-message", @"mail", @"add-to-contacts"];
        } else {
            _avatarView.contacts = [conversation orderedContactsWithMaxCount:conversation.recipientCount keysToFetch:@[]];
            _avatarView.actionCategories = @[@"instant-message"];
        }
        _avatarView.name = conversation.hasDisplayName ? conversation.displayName : conversation.name;
        _avatarView.style = [conversation.businessConversation unsignedIntegerValue];
        [self setNeedsLayout];
    } else {
        [_avatarView removeFromSuperview];
        _avatarView = nil;
    }
}
- (void)setupAvatarView {
    _avatarView = [[%c(CKAvatarView) alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    _avatarView.asynchronousRendering = true;
    _avatarView.bypassActionValidation = true;
    _avatarView.showsContactOnTap = false;
    _avatarView.delegate = self;
    _avatarView.translatesAutoresizingMaskIntoConstraints = false;
    [_avatarView.widthAnchor constraintEqualToAnchor:_avatarView.heightAnchor].active = true;
    [_stackView addArrangedSubview:_avatarView];
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAvatarView:)]];
}
- (void)setupStackView {
    _stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, 52, 38)];
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionFill;
    [self.contentView addSubview:_stackView];
    _stackView.translatesAutoresizingMaskIntoConstraints = false;
    [_stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5].active = true;
    [_stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5].active = true;
    [_stackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = true;
    [_stackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = true;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    _conversation = nil;
    _tapHandler = nil;
    _avatarView.contact = nil;
    _avatarView.contacts = nil;
    _avatarView.name = nil;
    _avatarView.actionCategories = nil;
    _avatarView.style = 0;
}
- (void)layoutSubviews {
    [super layoutSubviews];

}
- (void)didTapOnAvatarView:(id)sender {
    _tapHandler(_conversation);
}
- (UIImageView * _Nullable)browserImage {
    return _avatarView.imageView;
}
- (UIViewController *)presentingViewControllerForAvatarView:(CNAvatarView *)avatarView {
    return [avatarView isKindOfClass:%c(CKAvatarView)] ? ((CKAvatarView *)avatarView).presentingViewController : nil;
}
@end