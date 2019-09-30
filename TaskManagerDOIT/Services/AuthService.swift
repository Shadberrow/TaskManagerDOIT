//
//  AuthService.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/29/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import Foundation
import RxSwift

struct Credentials {
    let email: String
    let password: String
}

struct AuthService {
    
    let session: YVURLSession
    
    init(session: YVURLSession = YVURLSession()) {
        self.session = session
    }
    
    func login(credentials: Credentials) -> Observable<YVEitherResult<AuthSuccessResponse, YVApiError>> {
        let endpoint = YVAuthEndpoint.login(email: credentials.email, password: credentials.password)
        return Observable<YVEitherResult<AuthSuccessResponse, YVApiError>>.create { obs in
            self.session.perform(withEndpoint: endpoint, completion: obs.onNext)
            return Disposables.create()
        }
    }
    
    func register(credentials: Credentials) -> Observable<YVEitherResult<AuthSuccessResponse, YVApiError>> {
        let endpoint = YVAuthEndpoint.register(email: credentials.email, password: credentials.password)
        return Observable<YVEitherResult<AuthSuccessResponse, YVApiError>>.create { obs in
            self.session.perform(withEndpoint: endpoint, completion: obs.onNext)
            return Disposables.create()
        }
    }
    
}
