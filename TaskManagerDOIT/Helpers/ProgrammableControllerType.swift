
//
//  ProgrammableControllerType.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import UIKit

protocol ProgrammableControllerType {
    func setupView()
    func setupSubviews()
    func addSubviews()
    func setupConstraints()
}

extension ProgrammableControllerType where Self: UIViewController {
    func activateProgrammatically() {
        setupSubviews()
        addSubviews()
        setupConstraints()
        setupView()
    }
}
