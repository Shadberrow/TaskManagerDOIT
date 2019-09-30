//
//  NetworkManager.swift
//  TaskManagerDOIT
//
//  Created by Yevhenii Veretennikov on 9/28/19.
//  Copyright © 2019 Yevhenii Veretennikov. All rights reserved.
//

import Foundation

enum YVHTTPMethod: String {
    case options         = "OPTIONS"
    case get             = "GET"
    case head            = "HEAD"
    case post            = "POST"
    case put             = "PUT"
    case patch           = "PATCH"
    case delete          = "DELETE"
    case trace           = "TRACE"
    case connect         = "CONNECT"
}

enum YVApiError: Swift.Error {
    case apiError
    case notImplemented
    
    case badResponse(AuthErrorMessage)
    case emptyData
}

extension YVApiError {
    func getMessage() -> (message: String, submessage: String?) {
        let message: String
        let submessage: String?
        
        switch self {
        case let .badResponse(loginResponse):
            message = loginResponse.message
            submessage = loginResponse.fields?.first?.value.first
        default: message = "Oops :("; submessage = "Unhandled error"
        }
        
        return (message, submessage)
    }
}

enum YVEitherResult<V, E: Swift.Error> {
    case value(V)
    case error(E)
}

protocol YVNetworkSession {
    var session: URLSession { get }
    func fetch<V: Codable>(withRequest request: URLRequest, completion: @escaping (YVEitherResult<V, YVApiError>) -> Void)
}

extension YVNetworkSession {
    func fetch<V: Codable>(withRequest request: URLRequest, completion: @escaping (YVEitherResult<V, YVApiError>) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { completion(.error(.apiError)); return }
            guard let data = data else { completion(.error(.emptyData)); return }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                if let info: AuthErrorMessage = try? data.decoded() {
                    completion(.error(.badResponse(info)))
                }
                return
            }
            
            if let result: V = try? data.decoded() {
                completion(.value(result)); return
            }
            
            print("OOPS!")
        }
        task.resume()
    }
}

protocol YVEndpoint {
    var baseUrl     : String { get }
    var path        : String { get }
    var queryItems  : [URLQueryItem] { get }
    var method      : YVHTTPMethod { get }
    var headers     : [String: String] { get }
    var body        : [String: Any] { get }
}

extension YVEndpoint {
    var baseUrl: String {
        return "https://testapi.doitserver.in.ua"
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var urlComponent: URLComponents {
        var component = URLComponents(string: baseUrl)
        component?.path = path
        component?.queryItems = queryItems.isEmpty ? nil : queryItems
        return component!
    }
    
    var request: URLRequest {
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = getHTTPBody()
        return request
    }
    
    var body: [String: Any] {
        return [:]
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    private func getHTTPBody() -> Data? {
        guard let contentType = headers["Content-Type"] else { return nil }
        if contentType.contains("application/json") {
            return try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } else { print(YVApiError.notImplemented); return nil }
    }
    
}

class YVURLSession: YVNetworkSession {
    
    var session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func perform<V: Codable>(withEndpoint endpoint: YVEndpoint, completion: @escaping ((YVEitherResult<V, YVApiError>) -> (Void))) {
        fetch(withRequest: endpoint.request, completion: completion)
    }
    
}

enum YVAuthEndpoint: YVEndpoint {
    
    case login(email: String, password: String)
    case register(email: String, password: String)
    
    var path: String {
        switch self {
        case .login(email: _, password: _):
            return "/api/auth"
        case .register(email: _, password: _):
            return "/api/users"
        }
    }
    
    var body: [String : Any] {
        switch self {
        case let .login(email: email, password: passwd):
            return ["email": email,
                    "password": passwd]
        case let .register(email: email, password: passwd):
            return ["email": email,
                    "password": passwd]
        }
    }
    
    var method: YVHTTPMethod {
        switch self {
        case .login(email: _, password: _):
            return .post
        case .register(email: _, password: _):
            return .post
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .login(email: _, password: _):
            return ["Content-Type" : "application/json"]
        case .register(email: _, password: _):
            return ["Content-Type" : "application/json"]
        }
    }
    
}


struct AuthErrorMessage: Codable {
    let message: String
    let fields: [String: [String]]?
}

struct AuthSuccessResponse: Codable {
    let token: String
}
