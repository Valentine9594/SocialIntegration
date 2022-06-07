//
//  TwitterService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 31/05/22.
//

import Foundation
import Swifter
import AuthenticationServices

//MARK: Social Media Services for Twitter Account
class TwitterService: NSObject, ITwitterAppleGoogleService{
    private var twitterManager: Swifter?
    private var callbackURL: URL!
    private var credentialToken: Credential.OAuthAccessToken?
    static let shared = TwitterService()
    let classTitle = "Twitter"
    
    private override init(){
        super.init()
        twitterManager = Swifter(consumerKey: TwitterModel.apiKey, consumerSecret: TwitterModel.apiKeySecret)
        callbackURL = URL(string: TwitterModel.callbackURL)!
    }
    
    //MARK: Setting up App Delegate for Twitter Account in application
    func setupAppDelegateURLOptions(url: URL) -> Bool{
        return Swifter.handleOpenURL(url, callbackURL: self.callbackURL)
    }
    
    //MARK: Setting up App Delegate for Twitter Account in application
    func setupSceneDelegate(url: URL){
        Swifter.handleOpenURL(url, callbackURL: self.callbackURL)
    }
    
    
    func login(fromViewController viewController: UIViewController, completion: @escaping ((UserModel?, SocialMediaServiceError?) -> Void)) {
        twitterManager?.authorize(withCallback: callbackURL, presentingFrom: viewController) { _, _ in
            self.credentialToken = self.twitterManager?.client.credential?.accessToken
            self.fetchUserInfo(completion: completion)
        }
    }
    
    func logout() {
        self.credentialToken = nil
        clearCookie()
    }
    
    func isUserSignedIn() -> Bool{
        return credentialToken != nil ? true : false
    }
    
    func fetchUserInfo(completion: @escaping ((UserModel?, SocialMediaServiceError?) -> Void)) {
        twitterManager?.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true) { jsonResponse in
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
        
            guard twitterid != nil, twitterName != nil, twitterEmail != nil, twitterProfilePicURL != nil else{
                completion(nil, .loginFailed)
                return }
            let userModel = UserModel(id: twitterid, firstName: twitterName, lastName: twitterName, email: twitterEmail, mobileNo: nil, profileImageURL: twitterProfilePicURL)
            completion(userModel, nil)
        } failure: { error in
            debugPrint("ERROR: \(error.localizedDescription)")
            completion(nil, .loginFailed)
        }

    }
    
    
}
//
//extension TwitterService: ASWebAuthenticationPresentationContextProviding{
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//
//    }
//
//}
