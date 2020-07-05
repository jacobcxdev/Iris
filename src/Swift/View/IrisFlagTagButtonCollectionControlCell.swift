//
//  IrisFlagTagButtonCollectionControlCell.swift
//  Iris
//
//  Created by Jacob Clayden on 18/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisFlagTagButtonCollectionControlCell: UICollectionViewCell {

    // MARK: - Private Properties
    private let control_ = IrisFlagTagButtonCollectionControl()

    // MARK: - Properties
    @objc public var control: IrisFlagTagButtonCollectionControl {
        control_
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
        control.backgroundColor = nil
        addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        control.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        control.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        control.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15).isActive = true
    }

    // MARK: - Override Funcs
    public override func prepareForReuse() {
        super.prepareForReuse()
        control.model = nil
        updateControl(animated: false)
    }

    // MARK: - Funcs
    @objc public func initPostDequeue(controlModel: IrisFlagTagButtonCollectionControlModel) {
        control.model = controlModel
        updateControl(animated: false)
    }

    @objc public func updateControl(animated: Bool) {
        control.updateButtonModels(control.model?.buttonModels ?? [IrisButtonModel](), animated: animated)
    }

}
