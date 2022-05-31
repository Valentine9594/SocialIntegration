//
//  AppleIntegration.swift
//  SocialIntegration
//
//  Created by neosoft on 23/05/22.
//

import Foundation
import AuthenticationServices

protocol AppleIntegrationDelegate{
    func completedAuthorization(userModel: UserModel?)
    func failedWithError(error: Error)
}

class AppleIntegration: NSObject{
    var userIdentifier: String?
//    var viewController: UIViewController?
    var delegate: AppleIntegrationDelegate?
    
    static let shared = AppleIntegration()
    
    private override init(){
        
    }
    
    func signInWithApple(viewController: UIViewController) -> ASAuthorizationAppleIDButton{
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(viewController, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        authorizationButton.cornerRadius = 10
        return authorizationButton
    }
    
    @objc func handleAppleIdRequest(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationcontroller = ASAuthorizationController(authorizationRequests: [request])
        authorizationcontroller.delegate = self
//        authorizationcontroller.presentationContextProvider = self
        authorizationcontroller.performRequests()
    }
    
    func checkCredentialState(){
        guard let userIdentifier = userIdentifier else {
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
}

extension AppleIntegration: ASAuthorizationControllerDelegate{
//    , ASAuthorizationControllerPresentationContextProviding
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        var userModel: UserModel?
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            userModel = UserModel(id: appleIDCredential.user, firstName: appleIDCredential.fullName?.givenName, lastName: appleIDCredential.fullName?.familyName, email: appleIDCredential.email, mobileNo: nil, profileImageURL: nil)
        }
        self.delegate?.completedAuthorization(userModel: userModel)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.delegate?.failedWithError(error: error)
    }
    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.viewController.view.window!
//    }
    
}
