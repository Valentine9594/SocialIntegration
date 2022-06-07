//
//  ISocilService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 02/06/22.
//

import UIKit

//MARK: Protocol which takes all social media integration to the app
protocol ISocialService {
    func login(fromViewController viewController: UIViewController,
                        completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void)
    func fetchUserInfo(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void)
    func logout()
    func clearCookie()
}

//MARK: Protocol specificly for Facebook inheriting the ISocialService Protocol
protocol IFacebookService: ISocialService{
    func getAccessToken() -> String?
}

//MARK: Protocol for the classes Apple, Google and Twitter
protocol ITwitterAppleGoogleService: ISocialService{
    func isUserSignedIn() -> Bool
}

//MARK: The function to clear cookies during logout/ Signout of user
extension ISocialService {
    func clearCookie (){
        URLCache.shared.removeAllCachedResponses()
        // Delete any associated cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
