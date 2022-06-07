//
//  ViewController.swift
//  SocialIntegration
//
//  Created by neosoft on 23/05/22.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var linkedinLoginButton: UIButton!
    var webView: WKWebView!
    lazy var facebookService: IFacebookService = FacebookService.shared
    lazy var googleService: ITwitterAppleGoogleService = GoogleService.shared
    lazy var appleService: ITwitterAppleGoogleService = AppleService.shared
    lazy var twitterService: ITwitterAppleGoogleService = TwitterService.shared
    lazy var linkedInService: ISocialService = LinkedInService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI(){
        webView = WKWebView()
        
        let allCornerRadius: CGFloat = 8
        facebookLoginButton.layer.cornerRadius = allCornerRadius
        appleLoginButton.layer.cornerRadius = allCornerRadius
        googleLoginButton.layer.cornerRadius = allCornerRadius
        linkedinLoginButton.layer.cornerRadius = allCornerRadius
        twitterLoginButton.layer.cornerRadius = allCornerRadius
        
        self.setLoginButtonTitle(loginButton: facebookLoginButton, loginButtonName: FacebookService.shared.classTitle, showLogin: (facebookService.getAccessToken() == nil))
        self.setLoginButtonTitle(loginButton: googleLoginButton, loginButtonName: GoogleService.shared.classTitle, showLogin: !googleService.isUserSignedIn())
        self.setLoginButtonTitle(loginButton: twitterLoginButton, loginButtonName: TwitterService.shared.classTitle, showLogin: !twitterService.isUserSignedIn())
        self.setLoginButtonTitle(loginButton: appleLoginButton, loginButtonName: AppleService.shared.classTitle, showLogin: !appleService.isUserSignedIn())
        self.setLoginButtonTitle(loginButton: linkedinLoginButton, loginButtonName: LinkedInService.shared.classTitle, showLogin: true)
    }
    
    @IBAction func clickedAppleLogin(_ sender: UIButton) {
        appleService.login(fromViewController: self) { [weak self] userModel, error in
            guard self != nil else{ return }
            if let user = userModel {
                self?.navigateToProfileViewController(userModel: user)
            }
            else if error != nil{
                self?.displayError(message: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func clickedGoogleSignIn(_ sender: UIButton) {
        if googleService.isUserSignedIn(){
            googleService.logout()
            setLoginButtonTitle(loginButton: googleLoginButton, loginButtonName: GoogleService.shared.classTitle, showLogin: true)
        }
        else{
            googleService.login(fromViewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel{
                    self?.setLoginButtonTitle(loginButton: self?.googleLoginButton, loginButtonName: GoogleService.shared.classTitle, showLogin: false)
                    self?.navigateToProfileViewController(userModel: user)
                }
                else if error != nil{
                    self?.displayError(message: error?.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func clickedLinkedInLoginButton(_ sender: UIButton) {
        linkedInService.login(fromViewController: self) { [weak self] userModel, error in
                guard self != nil else { return }
                if let user = userModel{
                    self?.navigateToProfileViewController(userModel: user)
                }
            }
    }
    
    @IBAction func clickedTwitterLoginButton(_ sender: UIButton) {
        debugPrint("Twitter Login: \(twitterService.isUserSignedIn())")
        if twitterService.isUserSignedIn(){
            twitterService.logout()
            setLoginButtonTitle(loginButton: twitterLoginButton, loginButtonName: TwitterService.shared.classTitle, showLogin: true)
        }
        else{
            twitterService.login(fromViewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel {
                    self?.setLoginButtonTitle(loginButton: self?.twitterLoginButton, loginButtonName: TwitterService.shared.classTitle, showLogin: false)
                    self?.navigateToProfileViewController(userModel: user)
                }
                else if error != nil{
                    self?.displayError(message: error?.localizedDescription)
                }
            }

        }
    }
    
    @IBAction func clickedFacebookButton(_ sender: UIButton) {
        if facebookService.getAccessToken() != nil{
            facebookService.logout()
            self.setLoginButtonTitle(loginButton: facebookLoginButton, loginButtonName: FacebookService.shared.classTitle, showLogin: true)
        }
        else{
            facebookService.login(fromViewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel {
                    self?.setLoginButtonTitle(loginButton: self?.facebookLoginButton, loginButtonName: FacebookService.shared.classTitle, showLogin: false)
                    
                    self?.navigateToProfileViewController(userModel: user)
                } else if error != nil{
                    self?.displayError(message: error?.localizedDescription)
                }

            }
        }

    }
    
    private func setLoginButtonTitle(loginButton: UIButton?, loginButtonName: String, showLogin: Bool){
        if showLogin{
            loginButton?.setTitle("\(loginButtonName) Login", for: .normal)
        }
        else{
             DispatchQueue.main.async {
                    loginButton?.setTitle("\(loginButtonName) Logout", for: .normal)
                }
            }
     }
    
    private func navigateToProfileViewController(userModel: UserModel?){
        DispatchQueue.main.async {
            let profileViewControllerStoryBoardID = "ProfileViewController"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileViewController = storyboard.instantiateViewController(withIdentifier: profileViewControllerStoryBoardID) as! ProfileViewController
            profileViewController.userModel = userModel
                self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    private func displayError(message: String?){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: false)
        }
    }
}


extension ViewController: SFSafariViewControllerDelegate{ }

