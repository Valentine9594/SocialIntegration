//
//  SocialMediaIntegration.swift
//  SocialIntegration
//
//  Created by neosoft on 26/05/22.
//

import UIKit

protocol SocialMediaIntegrationDelegate{
    func userDidSignIn(userModel: UserModel)
    func userDidSignOut()
}

class SocialMediaIntegration: NSObject{
    var linkedInLogin: LinkedInIntegration!
    var delegate: SocialMediaIntegrationDelegate?
    var presentingViewController: UIViewController?
    
    private override init() {
        super.init()
        self.linkedInLogin = LinkedInIntegration.shared
        
//        twitterLogin.delegate = self
        
        linkedInLogin.presentingViewController = presentingViewController
    }
    
    static let shared = SocialMediaIntegration()
    
    
    func setupAppDelegateURL(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return linkedInLogin.setupAppDelegateURLOptions(url: url)
    }
    
    
    
//    func setupDelegateToAppDelegate(appDelegate: UIApplicationDelegate){
//        googleLogin.delegate = appDelegate
//    }
}



//extension SocialMediaIntegration: TwitterIntegrationDelegate{
//    func userDidLogin(userModel: UserModel) {
//        self.delegate?.userDidSignIn(userModel: userModel)
//    }
//}
