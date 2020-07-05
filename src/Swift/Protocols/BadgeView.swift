//
//  BadgeView.swift
//  Iris
//
//  Created by Jacob Clayden on 25/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

public protocol BadgeView where Self: UIView {

    // MARK: - Properties
    var badgeLabel: UILabel { get }
    var badgeCount: UInt { get set }
    var badgeHidden: Bool { get set }

    // MARK: - Funcs
    func badgeFrameForRect(rect: CGRect) -> CGRect
    func layoutBadge()
    func setBadgeHidden(hidden: Bool, animated: Bool)
    func setupBadge()
    func updateBadge(animated: Bool)

}

// MARK: - Default Implementations
extension BadgeView {

    public func badgeFrameForRect(rect: CGRect) -> CGRect {
        let height = max(18, badgeLabel.frame.height + 5.0)
        let width = max(height, badgeLabel.frame.width + 10.0)
        return CGRect(x: rect.width - 5, y: -badgeLabel.frame.height / 2, width: width, height: height);
    }

    public func layoutBadge() {
        badgeLabel.sizeToFit()
        badgeLabel.frame = badgeFrameForRect(rect: frame)
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height / 2;
        badgeLabel.layer.masksToBounds = true;
    }

    public func setBadgeHidden(hidden: Bool, animated: Bool) {
        if badgeHidden == hidden {
            return
        }
        badgeHidden = hidden
        guard badgeCount != 0 else {
            return
        }
        if !hidden {
            badgeLabel.isHidden = hidden
        }
        badgeLabel.layer.removeAllAnimations()
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.badgeLabel.alpha = hidden ? 0 : 1
        }) { _ in
            self.badgeLabel.isHidden = hidden
        }
    }

    public func setupBadge() {
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textAlignment = .center
        badgeLabel.font = .preferredFont(forTextStyle: .caption1)
        badgeLabel.alpha = 0
        badgeLabel.isHidden = badgeHidden
        updateBadge(animated: false)
        addSubview(badgeLabel)
    }

    public func updateBadge(animated: Bool) {
        if badgeCount != 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            badgeLabel.text = formatter.string(from: NSNumber(value: badgeCount))
        }
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.badgeLabel.alpha = self.badgeHidden || self.badgeCount == 0 ? 0 : 1
        }
        layoutSubviews()
    }

}
