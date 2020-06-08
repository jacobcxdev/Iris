//
//  UIView+allSubviews.swift
//  Iris
//
//  Created by Jacob Clayden on 26/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

public extension UIView {

    // MARK: - Computed Properties
    @objc var allSubviews: [UIView] {
        allSubviews_()
    }

    // MARK: - Private Funcs
    private func allSubviews_() -> [UIView] {
        var allSubviews = [UIView]()
        for subview in subviews {
            allSubviews.append(subview)
            allSubviews += subview.allSubviews_()
        }
        return allSubviews
    }

}
