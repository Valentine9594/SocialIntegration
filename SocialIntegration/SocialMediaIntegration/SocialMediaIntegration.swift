//
//  SocialMediaIntegration.swift
//  SocialIntegration
//
//  Created by neosoft on 26/05/22.
//

import UIKit

class SocialMediaIntegration: NSObject{
    var facebookLogin: FacebookLogin!
    var appleLogin: AppleIntegration!
    var googleLogin: GoogleIntegration!
    var twitterLogin: TwitterInregration!
    var linkedInLogin: LinkedInIntegration!
    
    override init() {
        super.init()
        self.facebookLogin = FacebookLogin.shared
        self.appleLogin = AppleIntegration.shared
        self.googleLogin = GoogleIntegration.shared
        self.twitterLogin = TwitterInregration.shared
    }
    
    static let shared = SocialMediaIntegration()
    
    func setupAppDelegateLaunchingOptions(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        googleLogin.setupAppDelegate()
        facebookLogin.setupAppDelegate(application: application, launchOptions: launchOptions)
    }
    
    func setupAppDelegateURL(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return facebookLogin.setupURLOptions(app: app, url: url, options: options) || googleLogin.setupUrlOptions(url: url) || twitterLogin.setupAppDelegateURLOptions(url: url) || linkedInLogin.setupAppDelegateURLOptions(url: url)
    }
    
    func setupSceneDelegate(url: URL){
        facebookLogin.setupSceneDelegate(url: url)
        twitterLogin.setupSceneDelegate(url: url)
    }
    
//    func setupDelegateToAppDelegate(appDelegate: UIApplicationDelegate){
//        googleLogin.delegate = appDelegate
//    }
}
