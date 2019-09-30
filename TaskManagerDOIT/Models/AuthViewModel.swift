//
//  AuthViewModel.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import Foundation
import RxSwift

struct AuthViewModel: IOModel {
    
    var input: AuthViewModel.Input
    var output: AuthViewModel.Output
    
    private let toggleSubject = PublishSubject<Bool>()
    private let emailSubject = PublishSubject<String?>()
    private let passwordSubject = PublishSubject<String?>()
    private let buttonTapSubject = PublishSubject<Void>()
    private let authResultSubject = PublishSubject<YVEitherResult<AuthSuccessResponse, YVApiError>>()
    
    private let bag = DisposeBag()
    
    let service: AuthService
    
    struct Input {
        let toggleValue: AnyObserver<Bool>
        let emailValue: AnyObserver<String?>
        let passwordValue: AnyObserver<String?>
        let buttonTapped: AnyObserver<Void>
    }
    
    struct Output {
        let buttonTitle: Observable<String>
        let titleText: Observable<String>
        let isButtonEnabled: Observable<Bool>
        let authResult: Observable<YVEitherResult<AuthSuccessResponse, YVApiError>>
    }
    
    init(service: AuthService) {
        self.service = service
        
        let buttonTitleObservable = toggleSubject.asObservable().map({ $0 ? "Register" : "Log in" })
        let textTitleObservable = toggleSubject.asObservable().map({ $0 ? "Sign up" : "Sign in" })
        
        let credentials = Observable.combineLatest(emailSubject.asObservable().unwrap(),
                                                   passwordSubject.asObservable().unwrap(),
                                                   resultSelector: Credentials.init)
        
        let isEmailValid = emailSubject.asObservable().map({ ($0 ?? "").count > 0 })
        let isPassValid = passwordSubject.asObservable().map({ ($0 ?? "").count > 0 })
        let isButtonEnabled = Observable.combineLatest(isEmailValid, isPassValid) { $0 && $1 }
        
        input = Input(toggleValue: toggleSubject.asObserver(),
                      emailValue: emailSubject.asObserver(),
                      passwordValue: passwordSubject.asObserver(),
                      buttonTapped: buttonTapSubject.asObserver())
        
        output = Output(buttonTitle: buttonTitleObservable,
                        titleText: textTitleObservable,
                        isButtonEnabled: isButtonEnabled,
                        authResult: authResultSubject)
        
        buttonTapSubject
            .withLatestFrom(toggleSubject).filter({ !$0 })
            .withLatestFrom(credentials)
            .flatMap(service.login)
            .bind(to: authResultSubject).disposed(by: bag)
        
        buttonTapSubject
            .withLatestFrom(toggleSubject).filter({ $0 })
            .withLatestFrom(credentials)
            .flatMap(service.register)
            .bind(to: authResultSubject).disposed(by: bag)
    }
    
}
