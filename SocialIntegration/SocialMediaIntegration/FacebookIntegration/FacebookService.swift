//
//  FacebookService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 30/05/22.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

//MARK: Social Media Services for Facebook Account
class FacebookService: IFacebookService{
    private var loginManager: LoginManager
    let classTitle = "Facebook"
    static let shared = FacebookService()
    
    private init() {
        loginManager = LoginManager()
    }
        
    //MARK: Setting up App Delegate for Facebook Account in application
    func setupAppDelegate(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        ApplicationDelegate.shared.application(application,  didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setupURLOptions(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func setupSceneDelegate(url: URL){
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    
    func login(fromViewController viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        clearCookie()
        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController, handler: {(loginResult, error) in
            if error != nil {
                completion(nil, SocialMediaServiceError.loginFailed)
            }
            else if (loginResult?.isCancelled)! {
                completion(nil, SocialMediaServiceError.cancelled)
            }
            else {
                self.fetchUserInfo(completion: completion)
            }
        })
    }
    
    func fetchUserInfo(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        let requestFields = ["fields": "first_name, last_name, picture.type(large), email, id, gender, name"]
        let request = GraphRequest(graphPath: "me", parameters: requestFields, tokenString: getAccessToken(), version: nil, httpMethod: .get)
        request.start { connection, result, error in
            if error != nil{
                 completion(nil, .graphAPIFailed)
            } else {
                
                
                debugPrint("UserInfo: \(String(describing: result))")
                debugPrint("Result: \(result!)")
                if let res = result as? Data {
                        debugPrint("Converting FB result to data")
                        let userInfoModel = try? JSONDecoder().decode(FacebookModel.self, from: res)
                    debugPrint("UserInfo Full: \(String(describing: userInfoModel))")
                }
                
                
                let userInfo = result as! [String:Any]
                let userPic = userInfo["picture"] as! [String:Any]
                let userPicData = userPic["data"] as! [String:Any]
//                debugPrint("UserInfo: \(userPic["data"])")
                if let email = userInfo["email"] as? String {
                    let userModelRecieved = UserModel(id: userInfo["id"] as? String, firstName: userInfo["first_name"] as? String, lastName: userInfo["last_name"] as? String, email: email, mobileNo: nil, profileImageURL: userPicData["url"] as? String)
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
        clearCookie()
    }
    
    func getAccessToken() -> String?{
        AccessToken.current?.tokenString
    }
    func trdt() {
        
    }
}
