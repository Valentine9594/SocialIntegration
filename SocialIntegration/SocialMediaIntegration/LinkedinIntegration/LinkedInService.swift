//
//  LinkedInService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 31/05/22.
//

import Foundation
import UIKit

protocol ILinkedInService{
    func login(viewController: UIViewController, completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void)
    func logout()
    func fetchUserData(completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void)
    func userDidSignIn() -> Bool
}

class LinkedInService: NSObject, ILinkedInService{
    static let shared = LinkedInService()
    
    private override init(){
        super.init()
        
    }
    
    func login(viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        
    }
    
    func logout() {
        
    }
    
    func fetchUserData(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        
    }
    
    func userDidSignIn() -> Bool {
        return false
    }
}
