//
//  Constants.swift
//  SocialIntegration
//
//  Created by neosoft on 26/05/22.
//

import Foundation

enum SocialSignInType{
    case google
    case twitter
    case facebook
    case apple
    case linkedIn
}

func clearCookie (){
    URLCache.shared.removeAllCachedResponses()
    // Delete any associated cookies
    if let cookies = HTTPCookieStorage.shared.cookies {
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}
