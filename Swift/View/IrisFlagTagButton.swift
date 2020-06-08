//
//  IrisFlagTagButton.swift
//  Iris
//
//  Created by Jacob Clayden on 02/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisFlagTagButton: IrisButton {

    // MARK: - Properties
    @objc public var conversationFlag: IrisConversationFlag
    @objc public var conversationTag: IrisConversationTag?

    // MARK: - Init Methods
    @objc public init(flag: IrisConversationFlag = .Shown, tag: IrisConversationTag? = nil) {
        conversationFlag = flag
        conversationTag = tag
        super.init()
    }

    required init?(coder: NSCoder) {
        conversationFlag = .Shown
        conversationTag = nil
        super.init(coder: coder)
    }

    // MARK: - Funcs

    @objc public func updateBadgeCount(shownUnreadCount: UInt, hiddenUnreadCount: UInt, animated: Bool) {
        switch conversationFlag {
        case .Hidden:
            badgeCount = hiddenUnreadCount
            model?.badgeCount = hiddenUnreadCount
        case .Tagged:
            if let tag = conversationTag {
                badgeCount = tag.unreadCount
                model?.badgeCount = tag.unreadCount
            }
        default:
            badgeCount = shownUnreadCount
            model?.badgeCount = shownUnreadCount
        }
        updateBadge(animated: animated)
    }

}
