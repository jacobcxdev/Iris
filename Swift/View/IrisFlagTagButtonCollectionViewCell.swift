//
//  IrisFlagTagButtonCollectionViewCell.swift
//  Iris
//
//  Created by Jacob Clayden on 23/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

class IrisFlagTagButtonCollectionViewCell: IrisButtonCollectionViewCell {

    // MARK: - Private Properties
    private let button_ = IrisFlagTagButton()

    // MARK: - Properties
    override var button: IrisFlagTagButton {
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
        button.conversationFlag = .Shown
        button.conversationTag = nil
        button.setImage(nil, for: .normal)
        button.tintColor = .systemBlue
    }

    override func initPostDequeue(buttonModel: IrisButtonModel) {
        button.conversationFlag = (buttonModel as? IrisFlagTagButtonModel)?.conversationFlag ?? .Shown
        button.conversationTag = (buttonModel as? IrisFlagTagButtonModel)?.conversationTag
        super.initPostDequeue(buttonModel: buttonModel)
    }

    override func updateButton(animated: Bool) {
        if button.conversationFlag != (button.model as? IrisFlagTagButtonModel)?.conversationFlag || button.conversationTag != (button.model as? IrisFlagTagButtonModel)?.conversationTag {
            (button.model as? IrisFlagTagButtonModel)?.updateFlagTag()
        }
        super.updateButton(animated: animated)
    }

}
