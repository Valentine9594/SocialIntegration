//
//  FacebookService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 30/05/22.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

enum SocialMediaServiceError: Error {
    /** User denied the email permission. */
    case emailDenied
    /** User doesn't have an email associated with their account. */
    case noEmail
    /** User cancelled the operation. */
    case cancelled
    /** Attempt to login failed. */
    case loginFailed
    /** Attempt to fetch users information failed */
    case graphAPIFailed
    /** User's access token is no longer valid or they have been logged out.*/
    case sessionExpired
}

protocol IFacebookService{
    func login(fromViewController viewController: UIViewController,
                        completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void)
    func getUserInfo(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void)
    func logout()
    func getAccessToken() -> String?
}

class FacebookService: IFacebookService{
    private var loginManager: LoginManager
    static let shared = FacebookService()
    
    private init() {
        loginManager = LoginManager()
    }
        
    func setupAppDelegate(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
//        _ = FBLoginButton.self
        ApplicationDelegate.shared.application(application,  didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setupURLOptions(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func setupSceneDelegate(url: URL){
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    
    func login(fromViewController viewController: UIViewController,
               completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        clearCookie()
        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController, handler: {(loginResult, error) in
            if error != nil {
                completion(nil, SocialMediaServiceError.loginFailed)
            }
            else if (loginResult?.isCancelled)! {
                completion(nil, SocialMediaServiceError.cancelled)
            }
            else {
                self.getUserInfo(completion: completion)
            }
        })
    }
    
    private func clearCookie (){
        URLCache.shared.removeAllCachedResponses()
        // Delete any associated cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }

    
    func getUserInfo(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        let requestFields = ["fields": "first_name, last_name, picture.type(large), email, id, gender, name"]
        let request = GraphRequest(graphPath: "me", parameters: requestFields, tokenString: getAccessToken(), version: nil, httpMethod: .get)
        request.start { connection, result, error in
            if error != nil{
                 completion(nil, .graphAPIFailed)
            } else {
                let userInfo    = result as! [String:Any]
                if let email = userInfo["email"] as? String {
                    let userModelRecieved = UserModel(id: userInfo["id"] as? String, firstName: userInfo["first_name"] as? String, lastName: userInfo["last_name"] as? String, email: email, mobileNo: nil, profileImageURL: userInfo["picture.type(large)"] as? String)
                         completion(userModelRecieved, nil)
                }
                else {
                    completion(nil, .noEmail)
                }
            }
        
    }
    }
        func logout() {
            loginManager.logOut()
        }
    
    func getAccessToken() -> String?{
        AccessToken.current?.tokenString
    }
}
