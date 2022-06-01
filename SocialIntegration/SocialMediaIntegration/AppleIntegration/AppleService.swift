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
    private var presentingViewController: UIViewController!
    
    private override init(){
        super.init()
        appleManager = ASAuthorizationAppleIDProvider()
    }
    
    func login(viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        self.presentingViewController = viewController
        let request = appleManager.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationcontroller = ASAuthorizationController(authorizationRequests: [request])
        authorizationcontroller.delegate = self
        authorizationcontroller.presentationContextProvider = self
        authorizationcontroller.performRequests()
        self.completionHandler = completion
    }
    
    func checkCredentialState() -> Bool{
        guard let userIdentifier = userIdentifier else {
            debugPrint("No User Identifier...")
            return false
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        var isSignedIn = false
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
            switch credentialState{
                case .authorized:
                    isSignedIn = true
            case .revoked, .notFound:
                    fallthrough
                default:
                    isSignedIn = false
            }
        }
        return isSignedIn
    }
    
    func isUserSignedIn() -> Bool{
        return checkCredentialState()
    }
    
    func logout() {
        clearCookie()
    }
    
    func fetchUserData(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
//        self.completionHandler = completion
//        let appleUser = appleManager.credentialState(forUserID: "")
    }
    
    
}

extension AppleService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        var userModel: UserModel?
        var socialMediaError: SocialMediaServiceError?
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            self.userIdentifier = appleIDCredential.user
            userModel = UserModel(id: appleIDCredential.user, firstName: appleIDCredential.fullName?.givenName, lastName: appleIDCredential.fullName?.familyName, email: appleIDCredential.email, mobileNo: nil, profileImageURL: nil)
        }
        else{
            socialMediaError = .cancelled
        }
//        self.checkCredentialState()
        self.completionHandler?(userModel, socialMediaError)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completionHandler?(nil, .loginFailed)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentingViewController.view.window!
    }

}
