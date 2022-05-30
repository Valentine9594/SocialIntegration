//
//  TwitterIntegration.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 28/05/22.
//

import Foundation
import Swifter

protocol TwitterIntegrationDelegate{
    func userDidLogin(userModel: UserModel)
    func userDidLogout()
}

class TwitterInregration: NSObject{
    var swifter: Swifter!
    var callbackURL: URL!
    static let shared = TwitterInregration()
    var delegate: TwitterIntegrationDelegate?
    
    override init(){
        super.init()
        self.swifter = Swifter(consumerKey: TwitterModel.apiKey, consumerSecret: TwitterModel.apiKeySecret)
        self.callbackURL = URL(string: TwitterModel.callbackURL)!
    }
    
    func setupAppDelegateURLOptions(url: URL) -> Bool{
        return Swifter.handleOpenURL(url, callbackURL: self.callbackURL)
//        return true
    }
    
    func setupSceneDelegate(url: URL){
        Swifter.handleOpenURL(url, callbackURL: self.callbackURL)
    }
    
    func setupLogin(viewController: UIViewController){
        self.swifter.authorize(withCallback: self.callbackURL, presentingFrom: viewController, success: { accessToken,_ in
            if let _accessToken = accessToken{
                self.fetchUserProfile(accessToken: _accessToken) { userModel in
                    guard let userModel = userModel else {
                        return
                    }
                    self.delegate?.userDidLogin(userModel: userModel)
                }
            }
        }, failure: { error in
            debugPrint("Error: \(error.localizedDescription)")
        })
    }
    
    func fetchUserProfile(accessToken: Credential.OAuthAccessToken, completionHandler: @escaping((UserModel?)->Void)){
        self.swifter.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true) { jsonResponse in
            
            // Twitter Id
            var twitterid: String?
            var twitterName: String?
            var twitterEmail: String?
            var twitterProfilePicURL: String?
            
            if let _twitterId = jsonResponse["id_str"].string {
                twitterid = _twitterId
            }

            // Twitter Name
            if let _twitterName = jsonResponse["name"].string {
                twitterName = _twitterName
            }

            // Twitter Email
            if let _twitterEmail = jsonResponse["email"].string {
                twitterEmail = _twitterEmail
            }

            // Twitter Profile Pic URL
            if let _twitterProfilePic = jsonResponse["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil) {
                twitterProfilePicURL = _twitterProfilePic
            }
        
            guard twitterid != nil, twitterName != nil, twitterEmail != nil, twitterProfilePicURL != nil else{ completionHandler(nil); return }
            
            completionHandler(UserModel(id: twitterid, firstName: twitterName, lastName: twitterName, email: twitterEmail, mobileNo: nil, profileImageURL: twitterProfilePicURL))
            
            
        } failure: { error in
            debugPrint("Error: \(error.localizedDescription)")
        }

    }
}
