//
//  IrisMenuButtonDimmingView.swift
//  Iris
//
//  Created by Jacob Clayden on 26/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public class IrisMenuButtonDimmingView: UIView {

    // MARK: - Weak Properties
    @objc public weak var menuButton: IrisMenuButton?

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
        backgroundColor = .black
        alpha = 0
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Override Funcs
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if let window = window {
            topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuButton?.isExpanded = false
    }

}

// MARK: - IrisMenuButtonDelegate
extension IrisMenuButtonDimmingView: IrisMenuButtonDelegate {

    public func menuButton(_ menuButton: IrisMenuButton, isExpandedDidUpdate isExpanded: Bool) {
        isUserInteractionEnabled = isExpanded
        UIView.animate(withDuration: 0.3) {
            self.alpha = isExpanded ? 0.2 : 0
        }
    }

}
