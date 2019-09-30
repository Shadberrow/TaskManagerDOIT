//
//  IOModel.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/29/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import Foundation

protocol IOModel {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}
