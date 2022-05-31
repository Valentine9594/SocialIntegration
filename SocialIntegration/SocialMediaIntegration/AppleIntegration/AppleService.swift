//
//  AppleService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 30/05/22.
//

import Foundation
import AuthenticationServices

protocol IAppleService{
    func login(viewController: UIViewController, completion: @escaping(UserModel?, SocialMediaServiceError?)->Void)
    func logout()
    func fetchUserData(completion: @escaping(UserModel?, SocialMediaServiceError?)->Void)
    func isUserSignedIn() -> Bool
}

class AppleService: NSObject, IAppleService{
    private var appleManager: ASAuthorizationAppleIDProvider!
    static let shared = AppleService()
    private var userIdentifier: String?
    private var completionHandler: ((UserModel?, SocialMediaServiceError?) -> Void)?
    
    private override init(){
        super.init()
        appleManager = ASAuthorizationAppleIDProvider()
    }
    
    func login(viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        let request = appleManager.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationcontroller = ASAuthorizationController(authorizationRequests: [request])
        authorizationcontroller.delegate = self
//        authorizationcontroller.presentationContextProvider = viewController as! ASAuthorizationControllerPresentationContextProviding
        authorizationcontroller.performRequests()
        self.completionHandler = completion
    }
    
    func checkCredentialState(){
        guard let userIdentifier = userIdentifier else {
            debugPrint("No User Identifier...")
            return
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
            switch credentialState{
                case .authorized:
                    debugPrint("Authorized")
                case .revoked:
                    debugPrint("Revoked")
                case .notFound:
                    debugPrint("Not Found")
                default:
                    break
            }
        }
    }
    
    func isUserSignedIn() -> Bool{
//        appleManager.getCredentialState(forUserID: , completion: <#T##(ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void#>)
        return false
    }
    
    func logout() {
        
    }
    
    func fetchUserData(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
//        self.completionHandler = completion
//        let appleUser = appleManager.credentialState(forUserID: "")
    }
    
    
}

extension AppleService: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        var userModel: UserModel?
        var socialMediaError: SocialMediaServiceError?
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            userModel = UserModel(id: appleIDCredential.user, firstName: appleIDCredential.fullName?.givenName, lastName: appleIDCredential.fullName?.familyName, email: appleIDCredential.email, mobileNo: nil, profileImageURL: nil)
        }
        else{
            socialMediaError = .cancelled
        }
        self.checkCredentialState()
        self.completionHandler?(userModel, socialMediaError)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completionHandler?(nil, .loginFailed)
    }
}
