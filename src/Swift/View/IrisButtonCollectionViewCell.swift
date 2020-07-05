//
//  IrisButtonCollectionViewCell.swift
//  Iris
//
//  Created by Jacob Clayden on 24/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

class IrisButtonCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties
    private let button_ = IrisButton()

    // MARK: - Properties
    var button: IrisButton {
        button_
    }

    // MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Private Funcs
    private func setup() {
        isUserInteractionEnabled = false
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    // MARK: - Override Funcs
    override func prepareForReuse() {
        super.prepareForReuse()
        button.model = nil
        updateButton(animated: false)
    }

    // MARK: - Funcs
    func initPostDequeue(buttonModel: IrisButtonModel) {
        button.model = buttonModel
        updateButton(animated: false)
    }

    func updateButton(animated: Bool) {
        if button.image(for: .normal) != button.model?.image ?? nil {
            button.setImage(button.model?.image, for: .normal)
        }
        if button.tintColor != button.model?.tintColour ?? .systemBlue {
            button.setTintColour(tintColour: button.model?.tintColour ?? .systemBlue, animated: animated)
        }
        if button.isHighlighted != button.model?.isHighlighted ?? false {
            button.setIsHighlighted(isHighlighted: button.model?.isHighlighted ?? false, animated: animated)
        }
        if button.isSelected != button.model?.isSelected ?? false {
            button.setIsSelected(isSelected: button.model?.isSelected ?? false, animated: animated)
        }
        if button.badgeCount != button.model?.badgeCount ?? 0 {
            button.setBadgeCount(badgeCount: button.model?.badgeCount ?? 0, animated: animated)
        }
        if button.badgeHidden != button.model?.badgeHidden ?? true {
            button.setBadgeHidden(hidden: button.model?.badgeHidden ?? true, animated: animated)
        }
        if button.alpha != button.model?.alpha ?? 1 {
            button.setAlpha(alpha: button.model?.alpha ?? 1, animated: animated)
        }
    }

}
