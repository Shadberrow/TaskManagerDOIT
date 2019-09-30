//
//  Scene.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import UIKit

enum Scene {
    case authViewController(AuthViewModel)
}


extension Scene {
    func viewController() -> UIViewController {
        switch self {
        case let .authViewController(model):
            var controller = AuthViewController()
            controller.bind(to: model)
            return controller
        }
    }
}
