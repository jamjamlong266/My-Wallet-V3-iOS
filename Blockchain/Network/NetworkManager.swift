//
//  NetworkManager.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Alamofire
import RxSwift

typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

typealias JSON = [String: Any]

typealias URLParameters = [String: Any]

/**
 Manages network related tasks such as requests and sessions.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */

@objc
class NetworkManager: NSObject, URLSessionDelegate {

    // MARK: - Properties

    /// The instance variable used to access functions of the `NetworkManager` class.
    static let shared = NetworkManager()

    /// Default unknown network error
    static let unknownNetworkError = NSError(domain: "NetworkManagerDomain", code: -1, userInfo: nil)

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc class func sharedInstance() -> NetworkManager {
        return NetworkManager.shared
    }

    @objc var session: URLSession!

    fileprivate var sessionConfiguration: URLSessionConfiguration!

    // MARK: - Initialization

    override init() {
        super.init()
        sessionConfiguration = URLSessionConfiguration.default
        if let userAgent = NetworkManager.userAgent {
            sessionConfiguration.httpAdditionalHeaders = ["User-Agent": userAgent]
        }
        if #available(iOS 11.0, *) {
            sessionConfiguration.waitsForConnectivity = true
        }
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        disableUIWebViewCaching()
        persistServerSessionIDForNewUIWebViews()
    }

    // MARK: - HTTP Requests

    /// Performs a network request and returns an Observable emitting the HTTPURLResponse along with the
    /// decoded response data. The response data will be attempted to be decoded as a JSON, however if it
    /// fails, it will be attempted to be decoded as a String. It is up to the observer to check the type.
    ///
    /// - Parameters:
    ///   - url: the URL for the request (e.g. "http://blockchain.info/uuid-generator?n=3")
    ///   - method: the HTTP method
    ///   - parameters: the parameters for the request
    /// - Returns: the Observable returning the HTTPURLResponse and the decoded response data
    func requestJsonOrString(
        _ url: String,
        method: HttpMethod,
        parameters: URLParameters? = nil
    ) -> Observable<(HTTPURLResponse, Any)> {

        let dataRequestObservable = Observable.create { (observer: AnyObserver<DataRequest>) -> Disposable in
            let request = SessionManager.default.request(
                url,
                method: method.toAlamofireHTTPMethod,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: nil
            )
            observer.onNext(request)
            observer.onCompleted()
            return Disposables.create()
        }
        return dataRequestObservable.flatMap { request -> Observable<(HTTPURLResponse, Any)> in
            return request.responseJSONObservable()
                .catchError { _ -> Observable<(HTTPURLResponse, Any)> in
                    return request.responseStringObservable()
                }
        }
    }

    // MARK: - URLSessionDelegate

    // TODO: find place to put UIApplication.shared.isNetworkActivityIndicatorVisible

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        let host = challenge.protectionSpace.host
        print("Received challenge from \(host)")
        if BlockchainAPI.Endpoints.rawValues.contains(host) ||
            BlockchainAPI.PartnerEndpoints.rawValues.contains(host) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}

    // MARK: - Private Functions

    fileprivate func persistServerSessionIDForNewUIWebViews() {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookieAcceptPolicy = .always
    }

    fileprivate func disableUIWebViewCaching() {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }
}

extension DataRequest {
    func responseJSONObservable() -> Observable<(HTTPURLResponse, Any)> {
        return Observable.create { [unowned self] observer -> Disposable in
            self.responseJSON { jsonResponse in
                if let error = jsonResponse.result.error {
                    observer.onError(error)
                    return
                }
                guard let response = jsonResponse.response, let result = jsonResponse.result.value else {
                    observer.onError(NetworkManager.unknownNetworkError)
                    return
                }
                observer.onNext((response, result))
                observer.onCompleted()

            }
            return Disposables.create {
                self.cancel()
            }
        }
    }

    func responseStringObservable() -> Observable<(HTTPURLResponse, Any)> {
        return Observable.create { [unowned self] observer -> Disposable in
            self.responseString { stringResponse in
                if let error = stringResponse.result.error {
                    observer.onError(error)
                    return
                }
                guard let response = stringResponse.response, let result = stringResponse.result.value else {
                    observer.onError(NetworkManager.unknownNetworkError)
                    return
                }
                observer.onNext((response, result))
                observer.onCompleted()

            }
            return Disposables.create {
                self.cancel()
            }
        }
    }
}

extension HttpMethod {

    /// Transforms this HttpMethod to an Alamofire.HTTPMethod
    var toAlamofireHTTPMethod: HTTPMethod {
        switch self {
        case .get:
            return HTTPMethod.get
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        }
    }
}
