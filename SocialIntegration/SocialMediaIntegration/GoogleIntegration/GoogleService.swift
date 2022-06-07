//
//  GoogleService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 30/05/22.
//

import Foundation
import GoogleSignIn

//MARK: Social Media Services for Google Account
class GoogleService: NSObject, ITwitterAppleGoogleService{
    private var googleManager: GIDSignIn!
    static let shared = GoogleService()
    private var completionHandler: ((UserModel?, SocialMediaServiceError?) -> Void)?
    let classTitle = "Google"
    
    private override init(){
        super.init()
        self.googleManager = GIDSignIn.sharedInstance()
    }
  
    //MARK: Setting up App Delegate for Google Account in application
    func setupAppDelegate(){
        googleManager.clientID = "206094931678-v2br94sq2b9p34vq7q7hrg3vdplr7ppo.apps.googleusercontent.com"
        googleManager.delegate = self
        googleManager.restorePreviousSignIn()
    }
    
    //MARK: Setting up App Delegate URL Options for Google Account in application
    func setupUrlOptions(url: URL) -> Bool{
        return googleManager.handle(url)
    }
    
    func login(fromViewController viewController: UIViewController,
               completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {        googleManager.presentingViewController = viewController
        googleManager.signIn()
        self.completionHandler = completion
    }
    
    func logout() {
        googleManager.signOut()
        clearCookie()
    }
    
    func fetchUserInfo(completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void) {
        if let user = googleManager.currentUser{
            var imageURL: URL?
            if user.profile.hasImage{
                imageURL = user.profile.imageURL(withDimension: 200)
            }
            let userModel = UserModel(id: user.userID, firstName: user.profile.givenName, lastName: user.profile.familyName, email: user.profile.email, mobileNo: nil, profileImageURL: imageURL?.absoluteString)
            completion(userModel, nil)
        }
        completion(nil, .loginFailed)
    }
    
    func isUserSignedIn() -> Bool{
//        googleManager.currentUser?.userID != nil ? true : false
        googleManager.hasPreviousSignIn()
    }
}

extension GoogleService: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.fetchUserInfo { usermodel, error in
            if error == nil{
                self.completionHandler?(usermodel, nil)
            }
        }
    }
}
