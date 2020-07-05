//
//  IrisButtonModel.swift
//  Iris
//
//  Created by Jacob Clayden on 23/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisButtonModel: NSObject {

    // MARK: - Properties
    @objc public var image: UIImage?
    @objc public var tintColour: UIColor
    @objc public var isHighlighted: Bool
    @objc public var isSelected: Bool
    @objc public var selectable: Bool
    @objc public var badgeCount: UInt
    @objc public var badgeHidden: Bool
    @objc public var alpha: CGFloat
    @objc public var tag: Int
    @objc public var target: AnyObject?
    @objc public var action: Selector?

    // MARK: - Init Methods
    @objc public init(image: UIImage? = nil, tintColour: UIColor = .systemBlue, isHighlighted: Bool = false, isSelected: Bool = false, selectable: Bool = true, badgeCount: UInt = 0, badgeHidden: Bool = true, alpha: CGFloat = 1, tag: Int = 0, target: AnyObject? = nil, action: Selector? = nil) {
        self.image = image
        self.tintColour = tintColour
        self.isHighlighted = isHighlighted
        self.isSelected = isSelected
        self.selectable = selectable
        self.badgeCount = badgeCount
        self.badgeHidden = badgeHidden
        self.alpha = alpha
        self.tag = tag
        self.target = target
        self.action = action
        super.init()
    }

}
