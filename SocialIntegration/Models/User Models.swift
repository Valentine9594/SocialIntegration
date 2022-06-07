//
//  Models.swift
//  SocialIntegration
//
//  Created by neosoft on 25/05/22.
//

import Foundation

struct UserModel{
    let id: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let mobileNo: String?
    
    let profileImageURL: String?
    
    var fullName: String?{
        return (firstName ?? "") + " " + (lastName ?? "")
    }
}


