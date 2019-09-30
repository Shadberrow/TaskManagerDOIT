//
//  AuthViewController.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import UIKit
import YVAnchor
import RxSwift
import RxCocoa

class AuthViewController: UIViewController, BindableType {
    
    typealias ViewModelType = AuthViewModel
    var viewModel: AuthViewModel!
    let bag = DisposeBag()
    
    private(set) var logoLabel: UILabel!
    private(set) var titleLabel: UILabel!
    private(set) var emailTextField: UITextField!
    private(set) var passwordTextField: UITextField!
    private(set) var authTypeLabel: UILabel!
    private(set) var authToggle: UISwitch!
    private(set) var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateProgrammatically()
    }
    
    func bindViewModel() {
        viewModel.output.buttonTitle.bind(to: authButton.rx.title(for: .normal)).disposed(by: bag)
        viewModel.output.titleText.bind(to: titleLabel.rx.text).disposed(by: bag)
        viewModel.output.isButtonEnabled.bind(to: authButton.rx.isEnabled).disposed(by: bag)
        viewModel.output.authResult.observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] result in
                switch result {
                case let .error(error):
                    self?.showAlert(withError: error)
                case .value(_):
                    self?.dismiss(animated: true, completion: nil)
                }
            }).disposed(by: bag)
        
        emailTextField.rx.text.bind(to: viewModel.input.emailValue).disposed(by: bag)
        passwordTextField.rx.text.bind(to: viewModel.input.passwordValue).disposed(by: bag)
        authToggle.rx.isOn.bind(to: viewModel.input.toggleValue).disposed(by: bag)
        authButton.rx.tap.bind(to: viewModel.input.buttonTapped).disposed(by: bag)
    }
    
    @objc
    func endEdit() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        authButton.layer.cornerRadius = 8
        super.viewDidLayoutSubviews()
    }
    
    private func showAlert(withError error: YVApiError) {
        let infoToDisplay = error.getMessage()
        let okAlertAction = UIAlertAction(title: "Got it", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: infoToDisplay.message, message: infoToDisplay.submessage, preferredStyle: .alert)
        alertViewController.addAction(okAlertAction)
        present(alertViewController, animated: true, completion: nil)
    }
    
}

extension AuthViewController: ProgrammableControllerType {
    
    func setupView() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEdit)))
    }
    
    func setupSubviews() {
        logoLabel = UILabel()
        logoLabel.attributedText = composeLogoTitle()
        logoLabel.numberOfLines = 2
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        emailTextField = UITextField()
        emailTextField.placeholder = "email"
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        
        passwordTextField = UITextField()
        passwordTextField.placeholder = "password"
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        authTypeLabel = UILabel()
        authTypeLabel.text = "Login / Register"
        authTypeLabel.textAlignment = .left
        
        authToggle = UISwitch()
        authToggle.isOn = false
        
        authButton = UIButton(type: .system)
        authButton.backgroundColor = .lightGray
        authButton.tintColor = .black
    }
    
    func addSubviews() {
        view.addSubview(logoLabel)
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(authTypeLabel)
        view.addSubview(authToggle)
        view.addSubview(authButton)
    }
    
    func setupConstraints() {
        logoLabel.pin(.top, to: topLayoutGuide.bottomAnchor, constant: 12)
        logoLabel.centerX(in: view)
        
        titleLabel.pin(.top, to: logoLabel.bottom, constant: 23)
        titleLabel.pin(.left, to: emailTextField.left)
        
        emailTextField.pin(.top, to: titleLabel.bottom, constant: 4)
        emailTextField.pin(.left, to: view.left, constant: 30)
        emailTextField.pin(.right, to: view.right, constant: 30)
        emailTextField.height(30)
        
        passwordTextField.pin(.top, to: emailTextField.bottom, constant: 12)
        passwordTextField.pin(.left, to: view.left, constant: 30)
        passwordTextField.pin(.right, to: view.right, constant: 30)
        passwordTextField.height(30)
        
        authTypeLabel.pin(.top, to: passwordTextField.bottom, constant: 20)
        authTypeLabel.pin(.left, to: passwordTextField.left)
        
        authToggle.pin(.right, to: passwordTextField.right)
        authToggle.centerY(in: authTypeLabel)
        
        authButton.pin(.top, to: authTypeLabel.bottom, constant: 20)
        authButton.pin(.left, to: view.left, constant: 30)
        authButton.pin(.right, to: view.right, constant: 30)
        authButton.height(40)
    }
    
    private func composeLogoTitle() -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributedString = NSMutableAttributedString()
        let line1 = NSAttributedString(string: "DOIT", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0/255, green: 97/255, blue: 167/255, alpha: 1),
                                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .heavy),
                                                                    NSAttributedString.Key.paragraphStyle : style,
                                                                    NSAttributedString.Key.kern : 0.7])
        let line2 = NSAttributedString(string: "\nSOFTWARE", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0/255, green: 97/255, blue: 167/255, alpha: 1),
                                                                          NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10, weight: .heavy),
                                                                          NSAttributedString.Key.paragraphStyle : style,
                                                                          NSAttributedString.Key.kern : 0.7])
        attributedString.append(line1)
        attributedString.append(line2)
        
        return attributedString
    }
    
}
