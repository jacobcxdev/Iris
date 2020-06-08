//
//  IrisMenuCollectionView.swift
//  Iris
//
//  Created by Jacob Clayden on 24/04/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

class IrisMenuCollectionView: IrisFlagTagButtonCollectionView {

    // MARK: - Private Properties
    private var heightConstraint: NSLayoutConstraint!

    // MARK: - Override Funcs
    override func setup() {
        super.setup()
        heightConstraint = heightAnchor.constraint(equalToConstant: 100)
        heightConstraint.priority = .init(rawValue: 999)
    }
    
    override func reloadData() {
        super.reloadData()
        heightConstraint.constant = collectionViewLayout.collectionViewContentSize.height
        layoutIfNeeded()
    }

    override func reloadSections(_ sections: IndexSet) {
        super.reloadSections(sections)
        heightConstraint.constant = collectionViewLayout.collectionViewContentSize.height
        layoutIfNeeded()
    }

}
