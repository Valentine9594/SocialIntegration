//
//  LinkedInModels.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 27/05/22.
//

import Foundation

struct LinkedInConstants{
    static let clientID = "77fn0gkjepofwk"
    static let clientSecret = "0uLlSurbLCvPSVse"
    static let redirect_url = "https://socialintegration.com/login/callback"
    static let scope = "r_liteprofile%20r_emailaddress"
    static let authURL = "https://www.linkedin.com/oauth/v2/authorization"
    static let tokenURL = "https://www.linkedin.com/oauth/v2/accessToken"
}


struct LinkedInEmailModel: Codable {
    let elements: [Element]
}


struct Element: Codable {
    let elementHandle: Handle
    let handle: String

    enum CodingKeys: String, CodingKey {
        case elementHandle = "handle~"
        case handle
    }
}


struct Handle: Codable {
    let emailAddress: String
}

struct LinkedInProfileModel: Codable {
    let firstName, lastName: StName
    let profilePicture: ProfilePicture
    let id: String
}

// MARK: - StName
struct StName: Codable {
    let localized: Localized
}

// MARK: - Localized
struct Localized: Codable {
    let enUS: String

    enum CodingKeys: String, CodingKey {
        case enUS = "en_US"
    }
}

// MARK: - ProfilePicture
struct ProfilePicture: Codable {
    let displayImage: DisplayImage

    enum CodingKeys: String, CodingKey {
        case displayImage = "displayImage~"
    }
}

// MARK: - DisplayImage
struct DisplayImage: Codable {
    let elements: [ProfilePicElement]
}

// MARK: - Element
struct ProfilePicElement: Codable {
    let identifiers: [ProfilePicIdentifier]
}

// MARK: - Identifier
struct ProfilePicIdentifier: Codable {
    let identifier: String
}
