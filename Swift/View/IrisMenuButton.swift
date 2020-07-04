//
//  IrisMenuButton.swift
//  Iris
//
//  Created by Jacob Clayden on 24/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisMenuButton: UIControl, BadgeView {

    // MARK: - Private Properties
    private var collectionView: UICollectionView!
    private var itemSize = CGSize(width: 30, height: 30)
    private var shadowRadius: CGFloat = 5
    private var heightConstraint: NSLayoutConstraint!
    private var previousTopButtonModel: IrisButtonModel?
    private var unorderedButtonModels = [IrisButtonModel]()
    private var pressTimer: Timer?
    private var scrollTimer: Timer?

    // MARK: - Weak Properties
    @objc public weak var delegate: IrisMenuButtonDelegate?

    // MARK: - Computed Properties
    @objc public var selectedButtonModel: IrisButtonModel? {
        buttonModels.first { $0.isSelected }
    }

    // MARK: - Observed Properties
    private var scrollDirection: ScrollDirection = .null {
        didSet {
            if scrollDirection == oldValue {
                return
            }
            scrollTimer?.invalidate()
            if scrollDirection != .null {
                scrollTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
                if !animatingHeight {
                    RunLoop.current.add(scrollTimer!, forMode: .default)
                }
            }
        }
    }
    private var animatingHeight = false {
        didSet {
            if isExpanded && scrollTimer != nil {
                RunLoop.current.add(scrollTimer!, forMode: .default)
            }
        }
    }
    @objc public var buttonModels = [IrisButtonModel]() {
        didSet {
            buttonModels.forEach { $0.badgeHidden = true }
        }
    }
    @objc public var isExpanded = false {
        didSet {
            if isExpanded != oldValue {
                if isExpanded {
                    becomeFirstResponder()
                    let haptics = UIImpactFeedbackGenerator(style: .rigid)
                    haptics.impactOccurred()
                }
                guard let sv = self.superview else {
                    return
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.animatingHeight = true
                    self.heightConstraint.isActive = !self.isExpanded
                    sv.layoutIfNeeded()
                    self.layer.shadowOpacity = self.isExpanded ? 1 : 0
                    self.collectionView.setContentOffset(.zero, animated: true)
                    self.setBadgeHidden(hidden: self.isExpanded, animated: true)
                    self.updateButtons(animated: true)
                }) { _ in
                    self.animatingHeight = false
                }
                delegate?.menuButton(self, isExpandedDidUpdate: isExpanded)
            }
        }
    }

    // MARK: - BadgeView Properties
    public var badgeLabel = UILabel()
    public var badgeCount: UInt = 0
    public var badgeHidden = false

    // MARK: - Init Methods
    @objc public init(buttonModels: [IrisButtonModel], topButtonModel: IrisButtonModel? = nil, itemSize: CGSize) {
        super.init(frame: .zero)
        self.buttonModels = buttonModels
        self.itemSize = itemSize
        unorderedButtonModels = buttonModels
        if let buttonModel = topButtonModel {
            unorderedButtonModels.removeAll { $0 == buttonModel }
            unorderedButtonModels.insert(buttonModel, at: 0)
        }
        unorderedButtonModels.enumerated().forEach {
            $1.badgeHidden = true
            $1.alpha = $0 == 0 ? 1 : 0
        }
        setup()
        selectFirstButton(animated: false)
    }

    public override init(frame: CGRect) {
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
        layer.shadowRadius = shadowRadius
        mask = UIView()
        mask?.backgroundColor = .black

        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: itemSize.height)
        heightConstraint.isActive = true

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = itemSize

        collectionView = IrisMenuCollectionView(frame: .zero, collectionViewLayout: layout)
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

        setupBadge()
    }

    // MARK: - Override Funcs
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else {
            return
        }
        topAnchor.constraint(greaterThanOrEqualTo: window.topAnchor).isActive = true
        bottomAnchor.constraint(lessThanOrEqualTo: window.bottomAnchor).isActive = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
        layoutBadge()

        let rect = maxButtonRect()
        mask?.frame.origin.x = rect.minX - shadowRadius * 2
        mask?.frame.origin.y = rect.minY - shadowRadius * 2
        mask?.frame.size.width = max(frame.width, rect.width) + shadowRadius * 4
        mask?.frame.size.height = frame.height - rect.minY + shadowRadius * 4
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if isExpanded {
            _ = updateButtonsWithTouch(touch, shouldHighlight: true, shouldSelect: false)
        } else {
            pressTimer?.invalidate()
            pressTimer = Timer.scheduledTimer(withTimeInterval: UILongPressGestureRecognizer().minimumPressDuration, repeats: false, block: { _ in
                self.isExpanded = true
            })
        }
        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if isExpanded {
            _ = updateButtonsWithTouch(touch, shouldHighlight: true, shouldSelect: false)
            let y = touch.location(in: self).y
            if y < frame.minY + itemSize.height {
                scrollDirection = .up
            } else if y > frame.maxY - itemSize.height {
                scrollDirection = .down
            } else {
                scrollDirection = .null
            }
        } else {
            scrollDirection = .null
        }
        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else {
            return
        }
        if isExpanded {
            if !updateButtonsWithTouch(touch, shouldHighlight: false, shouldSelect: true) {
                selectFirstButton(animated: true)
            }
            isExpanded = false
        } else {
            selectFirstButton(animated: true)
            pressTimer?.fire()
            pressTimer?.invalidate()
        }
        scrollDirection = .null
    }

    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        reloadCollectionView(animated: true)
        isExpanded = false
        return true
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
        unorderedButtonModels.enumerated().forEach { $1.isSelected = $0 == 0 }
        updateButtons(animated: animated)
    }

    func updateButtonsWithTouch(_ touch: UITouch, shouldHighlight: Bool, shouldSelect: Bool) -> Bool {
        var newButtonModel: IrisButtonModel?
        let indexPath = collectionView.indexPathForItem(at: touch.location(in: collectionView))
        if let indexPath = indexPath {
            newButtonModel = unorderedButtonModels[indexPath.row]
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
        if shouldSelect {
            reloadCollectionView(topButtonModel: buttonModel.isSelected ? buttonModel : unorderedButtonModels.first, animated: true)
            if let action = buttonModel.action {
                buttonModel.target?.perform(action, with: buttonModel, afterDelay: 0)
            }
        } else {
            updateButtons(animated: true)
        }
        return true
    }

    @objc public func reloadCollectionView(topButtonModel buttonModel: IrisButtonModel? = nil, animated: Bool) {
        collectionView.performBatchUpdates({
            previousTopButtonModel = unorderedButtonModels.first
            unorderedButtonModels = buttonModels
            if let buttonModel = buttonModel {
                unorderedButtonModels.removeAll { $0 == buttonModel }
                unorderedButtonModels.insert(buttonModel, at: 0)
            }
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
        selectFirstButton(animated: animated)
    }

    @objc public func revertToPreviousButton() {
        reloadCollectionView(topButtonModel: previousTopButtonModel, animated: true)
    }

    @objc public func updateButtonModels(_ buttonModels: [IrisButtonModel], topButtonModel: IrisButtonModel? = nil, animated: Bool) {
        self.buttonModels = buttonModels
        reloadCollectionView(topButtonModel: topButtonModel, animated: animated)
        updateButtons(animated: animated)
    }

    func updateButtons(animated: Bool) {
        unorderedButtonModels.enumerated().forEach {
            $1.badgeHidden = !isExpanded
            $1.alpha = isExpanded || $0 == 0 ? 1 : 0
        }
        (collectionView.visibleCells as! [IrisButtonCollectionViewCell]).forEach { $0.updateButton(animated: animated) }
    }

    @objc public func updateButtonBadges(shownUnreadCount: UInt, hiddenUnreadCount: UInt, shouldSecureHiddenList: Bool, animated: Bool) {
        buttonModels.forEach { ($0 as? IrisFlagTagButtonModel)?.updateBadgeCount(shownUnreadCount: shownUnreadCount, hiddenUnreadCount: hiddenUnreadCount, shouldSecureHiddenList: shouldSecureHiddenList) }
        updateButtons(animated: animated)
    }

    @objc public func scroll() {
        switch scrollDirection {
        case .up:
            if collectionView.contentOffset.y >= itemSize.height / 2 {
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y - itemSize.height), animated: true)
            }
        case .down:
            if collectionView.contentOffset.y < collectionView.contentSize.height - frame.maxY {
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + itemSize.height), animated: true)
            }
        default:
            break;
        }
    }

    @objc public func setBadgeCount(_ badgeCount: UInt, animated: Bool) {
        self.badgeCount = badgeCount
        updateBadge(animated: animated)
    }

    // MARK: - Enums
    enum ScrollDirection {
        case null, up, down
    }

}

// MARK: - UICollectionViewDataSource
extension IrisMenuButton: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        unorderedButtonModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if unorderedButtonModels[indexPath.row].isKind(of: IrisFlagTagButtonModel.self) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrisFlagTagButtonCollectionViewCell", for: indexPath) as! IrisFlagTagButtonCollectionViewCell
            cell.initPostDequeue(buttonModel: unorderedButtonModels[indexPath.row])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrisButtonCollectionViewCell", for: indexPath) as! IrisButtonCollectionViewCell
        cell.initPostDequeue(buttonModel: unorderedButtonModels[indexPath.row])
        return cell
    }

}
