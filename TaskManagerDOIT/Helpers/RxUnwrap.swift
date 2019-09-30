//
//  RxUnwrap.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/29/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    /**
     Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.
     - returns: An observable sequence of non-optional elements
     */
    public func unwrap<T>() -> Observable<T> where E == T? {
        return self.filter { $0 != nil }.map { $0! }
    }
}
