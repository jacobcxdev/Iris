//
//  IrisFlagTagButtonCollectionView.swift
//  Iris
//
//  Created by Jacob Clayden on 18/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import UIKit

class IrisFlagTagButtonCollectionView: UICollectionView {

    // MARK: - Override Properties
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    // MARK: - Init Methods
    required override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Override Funcs
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
        allSubviews.forEach { $0.isUserInteractionEnabled = false }
    }

    // MARK: - Funcs
    func setup() {
        clipsToBounds = false
        isUserInteractionEnabled = false
        isScrollEnabled = false
    }

}
