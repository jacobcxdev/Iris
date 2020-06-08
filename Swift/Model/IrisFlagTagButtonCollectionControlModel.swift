//
//  IrisFlagTagButtonCollectionControlModel.swift
//  Iris
//
//  Created by Jacob Clayden on 24/05/2020.
//  Copyright © 2020 JacobCXDev. All rights reserved.
//

import Foundation

@objc public class IrisFlagTagButtonCollectionControlModel: NSObject {

    // MARK: - Properties
    @objc public var buttonModels: [IrisButtonModel]

    // MARK: - Init Methods
    @objc public init(buttonModels: [IrisButtonModel] = [IrisButtonModel]()) {
        self.buttonModels = buttonModels
        super.init()
    }

}
