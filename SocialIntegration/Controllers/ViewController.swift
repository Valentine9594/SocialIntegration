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
    lazy var googleService: IGoogleService = GoogleService.shared
    lazy var appleService: IAppleService = AppleService.shared
    lazy var twitterService: ITwitterService = TwitterService.shared
    
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
        
        self.setLoginButtonTitle(loginButton: facebookLoginButton, loginButtonName: "Facebook", showLogin: (facebookService.getAccessToken() == nil))
        self.setLoginButtonTitle(loginButton: googleLoginButton, loginButtonName: "Google", showLogin: !googleService.isSignedIn())
        self.setLoginButtonTitle(loginButton: twitterLoginButton, loginButtonName: "Twitter", showLogin: !twitterService.isUserSignedIn())
        self.setLoginButtonTitle(loginButton: appleLoginButton, loginButtonName: "Apple", showLogin: !appleService.isUserSignedIn())
    }
    
    @IBAction func clickedAppleLogin(_ sender: UIButton) {
        appleService.login(viewController: self) { [weak self] userModel, error in
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
        if googleService.isSignedIn(){
            googleService.logout()
            setLoginButtonTitle(loginButton: googleLoginButton, loginButtonName: "Google", showLogin: true)
        }
        else{
            googleService.login(viewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel{
                    self?.setLoginButtonTitle(loginButton: self?.googleLoginButton, loginButtonName: "Google", showLogin: false)
                    self?.navigateToProfileViewController(userModel: user)
                }
                else if error != nil{
                    self?.displayError(message: error?.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func clickedLinkedInLoginButton(_ sender: UIButton) {
        LinkedInIntegration.shared.linkedInAuthVC()
    }
    
    @IBAction func clickedTwitterLoginButton(_ sender: UIButton) {
        if twitterService.isUserSignedIn(){
            twitterService.logout()
            setLoginButtonTitle(loginButton: twitterLoginButton, loginButtonName: "Twitter", showLogin: true)
        }
        else{
            twitterService.login(viewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel {
                    self?.setLoginButtonTitle(loginButton: self?.twitterLoginButton, loginButtonName: "Twitter", showLogin: false)
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
            self.setLoginButtonTitle(loginButton: facebookLoginButton, loginButtonName: "Facebook", showLogin: true)
        }
        else{
            facebookService.login(fromViewController: self) { [weak self] userModel, error in
                guard self != nil else{ return }
                if let user = userModel {
                    self?.setLoginButtonTitle(loginButton: self?.facebookLoginButton, loginButtonName: "Facebook", showLogin: false)
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
        let profileViewControllerStoryBoardID = "ProfileViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: profileViewControllerStoryBoardID) as! ProfileViewController
        profileViewController.userModel = userModel
            self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    private func displayError(message: String?){
        let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        self.present(alertController, animated: false)
    }
}


extension ViewController: SFSafariViewControllerDelegate{ }

