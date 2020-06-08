//
//  IrisMenuButtonDelegate.swift
//  Iris
//
//  Created by Jacob Clayden on 26/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

@objc public protocol IrisMenuButtonDelegate: class {

    // MARK: - Funcs
    func menuButton(_ menuButton: IrisMenuButton, isExpandedDidUpdate isExpanded: Bool)

}
