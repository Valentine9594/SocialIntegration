//
//  ViewController.swift
//  SocialIntegration
//
//  Created by neosoft on 23/05/22.
//

import UIKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import WebKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var linkedinLoginButton: UIButton!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
//        setupIFAlreadyLoggedIn()
    }

    private func setupUI(){
        webView = WKWebView()
        
        let allCornerRadius: CGFloat = 8
        facebookLoginButton.layer.cornerRadius = allCornerRadius
        appleLoginButton.layer.cornerRadius = allCornerRadius
        googleLoginButton.layer.cornerRadius = allCornerRadius
        linkedinLoginButton.layer.cornerRadius = allCornerRadius
        twitterLoginButton.layer.cornerRadius = allCornerRadius
        
        FacebookLogin.shared.delegate = self
        facebookLoginButton.delegate = FacebookLogin.shared
        facebookLoginButton.permissions = ["public_profile", "email"]
        
        AppleIntegration.shared.delegate = self
        GoogleIntegration.shared.delegate = self
        
        LinkedInIntegration.shared.presentingViewController = self
        
        TwitterInregration.shared.delegate = self
    }
    
    @IBAction func clickedAppleLogin(_ sender: UIButton) {
        AppleIntegration.shared.handleAppleIdRequest()
        AppleIntegration.shared.checkCredentialState()
    }
    
    
    @IBAction func clickedGoogleSignIn(_ sender: UIButton) {
        GoogleIntegration.shared.setupGoogleSignIn(presentingViewController: self)
    }
    
    
    @IBAction func clickedLinkedInLoginButton(_ sender: UIButton) {
        LinkedInIntegration.shared.linkedInAuthVC()
    }
    
    @IBAction func clickedTwitterLoginButton(_ sender: UIButton) {
        TwitterInregration.shared.setupLogin(viewController: self)
    }
    
    
    private func navigateToProfileViewController(userModel: UserModel?){
        let profileViewControllerStoryBoardID = "ProfileViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: profileViewControllerStoryBoardID) as! ProfileViewController
        profileViewController.userModel = userModel
            self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension ViewController: FaceBookLoginButtonDelegate{
    func userDidLogin() {
        FacebookLogin.shared.fetchUserData { _userModel in
            if let userModel = _userModel{
                self.navigateToProfileViewController(userModel: userModel)
            }
        }
    }
    
    func userDidLogout() {
        FacebookLogin.shared.setupLogout()
    }
}

extension ViewController: AppleIntegrationDelegate{
    func completedAuthorization(userModel: UserModel?) {
        self.navigateToProfileViewController(userModel: userModel)
    }
    
    func failedWithError(error: Error) {
        debugPrint("Eror: \(error.localizedDescription)")
    }
    
    
}

extension ViewController: GoogleIntegrationDelegate{
    func userDidSignIn(userModel: UserModel) {
        self.navigateToProfileViewController(userModel: userModel)
    }
    
    func userDidSignOut() {
        debugPrint("Signed Out")
    }
    
    
}

extension ViewController: TwitterIntegrationDelegate{
    func userDidLogin(userModel: UserModel) {
        self.navigateToProfileViewController(userModel: userModel)
    }
}

extension ViewController: SFSafariViewControllerDelegate{
    
}
