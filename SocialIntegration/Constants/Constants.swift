//
//  Constants.swift
//  SocialIntegration
//
//  Created by neosoft on 26/05/22.
//

import Foundation

enum SocialMediaServiceError: Error {
    /** User denied the email permission. */
    case emailDenied
    /** User doesn't have an email associated with their account. */
    case noEmail
    /** User cancelled the operation. */
    case cancelled
    /** Attempt to login failed. */
    case loginFailed
    /** Attempt to fetch users information failed */
    case graphAPIFailed
    /** User's access token is no longer valid or they have been logged out.*/
    case sessionExpired
}

enum SocialSignInType{
    case google
    case twitter
    case facebook
    case apple
    case linkedIn
}
