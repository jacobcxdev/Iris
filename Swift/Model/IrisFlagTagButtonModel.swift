//
//  IrisFlagTagButtonModel.swift
//  Iris
//
//  Created by Jacob Clayden on 23/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisFlagTagButtonModel: IrisButtonModel {

    // MARK: - Static Properties
    static let shownImage = UIImage(systemName: "person.crop.circle")
    static let shownTintColour: UIColor = .systemBlue
    static let hiddenImage = UIImage(systemName: "questionmark.circle")
    static let hiddenTintColour: UIColor = .systemBlue
    static let unreadImage = UIImage(systemName: "message.circle")
    static let unreadTintColour: UIColor = .systemBlue
    static let untaggedImage = UIImage(systemName: "minus.circle")
    static let untaggedTintColour: UIColor = .systemBlue
    static let defaultImage = UIImage(systemName: "circle.fill")
    static let defaultTintColour: UIColor = .systemBlue

    // MARK: - Observed Properties
    @objc public var conversationFlag: IrisConversationFlag {
        didSet {
            updateFlagTag()
        }
    }
    @objc public var conversationTag: IrisConversationTag? {
        didSet {
            updateFlagTag()
        }
    }

    // MARK: - Init Methods
    @objc public init(conversationFlag: IrisConversationFlag = .Shown, conversationTag: IrisConversationTag? = nil) {
        self.conversationFlag = conversationFlag
        self.conversationTag = conversationTag
        super.init()
        updateFlagTag()
    }

    // MARK: - Funcs
    @objc public func updateBadgeCount(shownUnreadCount: UInt, hiddenUnreadCount: UInt, shouldSecureHiddenList: Bool) {
        switch conversationFlag {
        case .Hidden:
            badgeCount = hiddenUnreadCount
        case .Unread:
            badgeCount = shouldSecureHiddenList ? shownUnreadCount : shownUnreadCount + hiddenUnreadCount
        case .Tagged:
            if let tag = conversationTag {
                badgeCount = tag.unreadCount
            }
        default:
            badgeCount = shownUnreadCount
        }
    }

    public func updateFlagTag() {
        switch conversationFlag {
        case .Shown:
            image = IrisFlagTagButtonModel.shownImage
            tintColour = conversationTag?.colour ?? IrisFlagTagButtonModel.shownTintColour
        case .Hidden:
            image = IrisFlagTagButtonModel.hiddenImage
            tintColour = conversationTag?.colour ?? IrisFlagTagButtonModel.hiddenTintColour
        case .Unread:
            image = IrisFlagTagButtonModel.unreadImage
            tintColour = conversationTag?.colour ?? IrisFlagTagButtonModel.unreadTintColour
        case .Tagged:
            image = conversationTag == nil ? IrisFlagTagButtonModel.untaggedImage : IrisFlagTagButtonModel.defaultImage
            tintColour = conversationTag?.colour ?? IrisFlagTagButtonModel.untaggedTintColour
        default:
            image = IrisFlagTagButtonModel.defaultImage
            tintColour = conversationTag?.colour ?? IrisFlagTagButtonModel.defaultTintColour
        }
    }

}
