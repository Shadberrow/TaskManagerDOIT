//
//  MainNavigationController.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    private func setupNavigation() {
        
        let service = AuthService()
        let model = AuthViewModel(service: service)
        let scene = Scene.authViewController(model)
        
//        viewControllers = [scene.viewController()]
        DispatchQueue.main.async {
            self.present(scene.viewController(), animated: true, completion: nil)
        }
    }
    
}
