//
//  FacebookLogin.swift
//  SocialIntegration
//
//  Created by neosoft on 25/05/22.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

protocol FaceBookLoginButtonDelegate {
    func userDidLogin()
    func userDidLogout()
}

class FacebookLogin: NSObject{
    var loginManager: LoginManager!
//    var facebookLoginButtonDelegate: LoginButtonDelegate?
    var delegate: FaceBookLoginButtonDelegate?
    var userModel: UserModel?
    
    static let shared = FacebookLogin()
    
    override init(){
        super.init()
//        self.facebookLoginButtonDelegate = self
        self.loginManager = LoginManager()
    }
    
    func setupAppDelegate(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        _ = FBLoginButton.self
        ApplicationDelegate.shared.application(application,  didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setupURLOptions(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func setupSceneDelegate(url: URL){
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func setupLogin(_ viewController: UIViewController){
        let permissions = ["public_profile", "email"]
        self.loginManager.logIn(permissions: permissions, from: viewController){ [weak self] (result, error) in
                guard self != nil else{ return }
                
                guard error == nil else{
                    return
                }
                
                guard result != nil else{ return }
            }
    }
    
    func fetchUserData(completionHandler: @escaping((UserModel?)->Void)){
        let requestFields = "first_name, last_name, email"
        let request = GraphRequest(graphPath: "me", parameters: ["fields": requestFields], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: .get)
        request.start { connection, result, error in
            if error == nil{
                guard let userInfo = result as? [String: Any] else{ return }
                let userModelRecieved = UserModel(id: nil, firstName: userInfo["first_name"] as? String, lastName: userInfo["last_name"] as? String, email: userInfo["email"] as? String, mobileNo: nil, profileImageURL: nil)
//                implement closures
                completionHandler(userModelRecieved)
            }
            else{
                completionHandler(nil)
            }
        }
    }
    
    func setupLogout(){
        self.loginManager.logOut()
    }
}

extension FacebookLogin: LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        self.delegate?.userDidLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        self.delegate?.userDidLogout()
    }
    
    
}
