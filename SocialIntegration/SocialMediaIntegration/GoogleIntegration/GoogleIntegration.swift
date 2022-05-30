//
//  GoogleIntegration.swift
//  SocialIntegration
//
//  Created by neosoft on 26/05/22.
//

import Foundation
import GoogleSignIn

protocol GoogleIntegrationDelegate {
    func userDidSignIn(userModel: UserModel)
    func userDidSignOut()
}

class GoogleIntegration: NSObject{
    var delegate: GoogleIntegrationDelegate?
    var googleSharedInstance: GIDSignIn!
    static let shared = GoogleIntegration()
    
    override init() {
        super.init()
        self.googleSharedInstance = GIDSignIn.sharedInstance()
    }
    
    func setupAppDelegate(){
        googleSharedInstance.clientID = "206094931678-v2br94sq2b9p34vq7q7hrg3vdplr7ppo.apps.googleusercontent.com"
        googleSharedInstance.delegate = self
        googleSharedInstance.restorePreviousSignIn()
    }
    
    func setupUrlOptions(url: URL) -> Bool{
        return googleSharedInstance.handle(url)
    }
    
    func setupGoogleSignIn(presentingViewController: UIViewController){
        googleSharedInstance.presentingViewController = presentingViewController
        googleSharedInstance.signIn()
    }
    
    func setupGoogleSignOut(){
        googleSharedInstance.signOut()
    }
    
    func fetchUserData(completionHandler: @escaping((UserModel?)->Void)){
        if let user = googleSharedInstance.currentUser{
            let userModel = UserModel(id: user.userID, firstName: user.profile.givenName, lastName: user.profile.familyName, email: user.profile.email, mobileNo: nil, profileImageURL: nil)
            completionHandler(userModel)
        }
        completionHandler(nil)
    }
    
}

extension GoogleIntegration: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue{
                debugPrint("User has not signed in or signed out")
            }
            else{
                debugPrint("Error: \(error.localizedDescription)")
            }
        }else{
            let userModel = UserModel(id: user.userID, firstName: user.profile.givenName, lastName: user.profile.familyName, email: user.profile.email, mobileNo: nil, profileImageURL: nil)
            self.delegate?.userDidSignIn(userModel: userModel)
        }

        NotificationCenter.default.post(name: .signInGoogle, object: nil)
    }
    
}


extension Notification.Name{
    static var signInGoogle: Notification.Name{
        return .init(rawValue: #function)
    }
}
