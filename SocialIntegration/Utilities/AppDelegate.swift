//
//  AppDelegate.swift
//  SocialIntegration
//
//  Created by neosoft on 23/05/22.
//

import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        SocialMediaIntegration.shared.googleLogin.delegate = self
        FacebookService.shared.setupAppDelegate(application: application, launchOptions: launchOptions)
        GoogleService.shared.setupAppDelegate()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        return SocialMediaURLOptions(app, open: url, options: options)
    }
    
    func SocialMediaURLOptions(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        FacebookService.shared.setupURLOptions(app: app, url: url, options: options) || GoogleService.shared.setupUrlOptions(url: url) || TwitterService.shared.setupAppDelegateURLOptions(url: url)
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

//extension AppDelegate: GoogleIntegrationDelegate{
//    func signInFor() {
//        NotificationCenter.default.post(name: .signInGoogle, object: nil)
//    }
//}
