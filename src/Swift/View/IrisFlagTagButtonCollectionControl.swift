//
//  IrisFlagTagButtonCollectionControl.swift
//  Iris
//
//  Created by Jacob Clayden on 18/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisFlagTagButtonCollectionControl: UIControl {

    // MARK: - Private Properties
    private var collectionView: UICollectionView!
    private var itemSize = CGSize(width: 30, height: 30)
    private var lastHighlightedButtonModel: IrisButtonModel?

    // MARK: - Properties
    var model: IrisFlagTagButtonCollectionControlModel?

    // MARK: - Observed Properties
    @objc public var buttonModels = [IrisButtonModel]() {
        didSet {
            buttonModels.forEach { $0.badgeHidden = true }
        }
    }

    // MARK: - Computed Properties
    @objc public var selectedButtonModel: IrisButtonModel? {
        buttonModels.first { $0.isSelected }
    }

    // MARK: - Init Methods
    @objc public init(buttonModels: [IrisButtonModel], itemSize: CGSize) {
        super.init(frame: .zero)
        self.buttonModels = buttonModels
        self.itemSize = itemSize
        buttonModels.forEach { $0.badgeHidden = true }
        setup()
        selectFirstButton(animated: false)
    }

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
        backgroundColor = .secondarySystemBackground
        layer.shadowColor = UIColor.systemFill.cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = itemSize

        collectionView = IrisFlagTagButtonCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(IrisButtonCollectionViewCell.self, forCellWithReuseIdentifier: "IrisButtonCollectionViewCell")
        collectionView.register(IrisFlagTagButtonCollectionViewCell.self, forCellWithReuseIdentifier: "IrisFlagTagButtonCollectionViewCell")
        collectionView.isUserInteractionEnabled = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - Override Funcs
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        _ = updateButtonsWithTouch(touch, shouldHighlight: true, shouldSelect: false)
        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        _ = updateButtonsWithTouch(touch, shouldHighlight: true, shouldSelect: false)
        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else {
            return
        }
        if !updateButtonsWithTouch(touch, shouldHighlight: false, shouldSelect: true) {
            selectLastHighlightedButton(animated: true)
            if let buttonModel = lastHighlightedButtonModel, let action = buttonModel.action {
                buttonModel.target?.perform(action, with: buttonModel, afterDelay: 0)
            }
        }
    }

    // MARK: - Funcs
    func maxButtonRect() -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        (collectionView.visibleCells as? [IrisButtonCollectionViewCell])?.map(\.button).forEach {
            let rect = $0.maxRect
            x = min(x, rect.minX)
            y = min(y, rect.minY)
            width = max(width, rect.width)
            height = max(height, rect.height)
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }

    func selectFirstButton(animated: Bool) {
        buttonModels.enumerated().forEach { $1.isSelected = $0 == 0 }
        updateButtons(animated: animated)
    }

    func selectLastHighlightedButton(animated: Bool) {
        buttonModels.forEach { $0.isSelected = $0 == lastHighlightedButtonModel }
        updateButtons(animated: animated)
    }

    func updateButtonsWithTouch(_ touch: UITouch, shouldHighlight: Bool, shouldSelect: Bool) -> Bool {
        var newButtonModel: IrisButtonModel?
        let indexPath = collectionView.indexPathForItem(at: touch.location(in: collectionView))
        if let indexPath = indexPath {
            newButtonModel = buttonModels[indexPath.row]
        }
        buttonModels.forEach {
            if $0 != newButtonModel {
                $0.isHighlighted = false
                $0.isSelected = false
            }
        }
        guard let buttonModel = newButtonModel else {
            updateButtons(animated: true)
            return false
        }
        if !buttonModel.isHighlighted {
            let haptics = UISelectionFeedbackGenerator()
            haptics.selectionChanged()
        }
        buttonModel.isHighlighted = shouldHighlight
        buttonModel.isSelected = shouldSelect && buttonModel.selectable
        if shouldHighlight {
            lastHighlightedButtonModel = buttonModel
        }
        if shouldSelect {
            if let action = buttonModel.action {
                buttonModel.target?.perform(action, with: buttonModel, afterDelay: 0)
            }
        }
        updateButtons(animated: true)
        return true
    }

    @objc public func reloadCollectionView(selectFirstButton shouldSelectFirstButton: Bool, animated: Bool) {
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
        if shouldSelectFirstButton {
            selectFirstButton(animated: animated)
        }
    }

    @objc public func updateButtonModels(_ buttonModels: [IrisButtonModel], animated: Bool) {
        self.buttonModels = buttonModels
        reloadCollectionView(selectFirstButton: !buttonModels.map(\.isSelected).contains(true), animated: animated)
        updateButtons(animated: animated)
    }

    @objc public func updateButtons(animated: Bool) {
        (collectionView.visibleCells as! [IrisButtonCollectionViewCell]).forEach { $0.updateButton(animated: animated) }
    }

    @objc public func updateButtonBadges(shownUnreadCount: UInt, hiddenUnreadCount: UInt, shouldSecureHiddenList: Bool, animated: Bool) {
        buttonModels.forEach { ($0 as? IrisFlagTagButtonModel)?.updateBadgeCount(shownUnreadCount: shownUnreadCount, hiddenUnreadCount: hiddenUnreadCount, shouldSecureHiddenList: shouldSecureHiddenList) }
        updateButtons(animated: true)
    }

}

// MARK: - UICollectionViewDataSource
extension IrisFlagTagButtonCollectionControl: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        buttonModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if buttonModels[indexPath.row].isKind(of: IrisFlagTagButtonModel.self) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrisFlagTagButtonCollectionViewCell", for: indexPath) as! IrisFlagTagButtonCollectionViewCell
            cell.initPostDequeue(buttonModel: buttonModels[indexPath.row])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrisButtonCollectionViewCell", for: indexPath) as! IrisButtonCollectionViewCell
        cell.initPostDequeue(buttonModel: buttonModels[indexPath.row])
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension IrisFlagTagButtonCollectionControl: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = itemSize.width * CGFloat(collectionView.numberOfItems(inSection: section))
        let inset = (collectionView.contentSize.width - width) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

}
