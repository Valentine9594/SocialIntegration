//
//  LinkedInService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 31/05/22.
//


import UIKit
import WebKit

protocol ILinkedInService{
    func login(viewController: UIViewController, completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void)
    func logout()
    func fetchUserData(completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void)
    func userDidSignIn() -> Bool
}

class LinkedInService: NSObject, ILinkedInService{
    static let shared = LinkedInService()
    private var presentingViewController: UIViewController?
    
    private override init(){
        super.init()
    }
    
    func login(viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        self.presentingViewController = viewController
        
        let linkedInVC = UIViewController()
        let webView = popUpViewControllerWebView(linkedInVC: linkedInVC)

        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        let authURLFull = LinkedInConstants.authURL + "?response_type=code&client_id=" + LinkedInConstants.clientID + "&scope=" + LinkedInConstants.scope + "&state=" + state + "&redirect_uri=" + LinkedInConstants.redirect_url

        let urlRequest = URLRequest.init(url: URL(string: authURLFull)!)
        webView.load(urlRequest)

        let navController = popUpViewControllerInNavigationController(presentingViewController: viewController, linkedInVC: linkedInVC)
        viewController.present(navController, animated: true, completion: nil)
    }
    
    private func popUpViewControllerWebView(linkedInVC: UIViewController) -> WKWebView{
        let webView = WKWebView()
        webView.navigationDelegate = self
        linkedInVC.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: linkedInVC.view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: linkedInVC.view.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: linkedInVC.view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: linkedInVC.view.trailingAnchor).isActive = true
        return webView
    }
    
    private func popUpViewControllerInNavigationController(presentingViewController: UIViewController,linkedInVC: UIViewController) -> UINavigationController{
        let navController = UINavigationController(rootViewController: linkedInVC)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        linkedInVC.navigationItem.leftBarButtonItem = cancelButton
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        linkedInVC.navigationItem.rightBarButtonItem = refreshButton
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navController.navigationBar.titleTextAttributes = textAttributes
        linkedInVC.navigationItem.title = "linkedin.com"
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.tintColor = UIColor.white
        navController.navigationBar.barTintColor = UIColor.black
        navController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        navController.modalTransitionStyle = .coverVertical
        return navController
    }
    
    @objc func cancelAction() {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }

    @objc func refreshAction() {
            (self.presentingViewController as? ViewController)?.webView.reload()
    }
    
    func logout() {
        
    }
    
    func fetchUserData(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        
    }
    
    func userDidSignIn() -> Bool {
        return false
    }
    
    private func fetchLinkedInUserProfile(accessToken: String) {
            let tokenURLFull = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))&oauth2_access_token=\(accessToken)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let verify: NSURL = NSURL(string: tokenURLFull!)!
            let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error == nil {
                    let linkedInProfileModel = try? JSONDecoder().decode(LinkedInProfileModel.self, from: data!)
                    
                    //AccessToken
                    print("LinkedIn Access Token: \(accessToken)")
                    
                    // LinkedIn Id
                    let linkedinId: String! = linkedInProfileModel?.id
                    print("LinkedIn Id: \(linkedinId ?? "")")

                    // LinkedIn First Name
                    let linkedinFirstName: String! = linkedInProfileModel?.firstName.localized.enUS
                    print("LinkedIn First Name: \(linkedinFirstName ?? "")")

                    // LinkedIn Last Name
                    let linkedinLastName: String! = linkedInProfileModel?.lastName.localized.enUS
                    print("LinkedIn Last Name: \(linkedinLastName ?? "")")

                    // LinkedIn Profile Picture URL
                    let linkedinProfilePic: String!

                    /*
                     Change row of the 'elements' array to get diffrent size of the profile url
                     elements[0] = 100x100
                     elements[1] = 200x200
                     elements[2] = 400x400
                     elements[3] = 800x800
                    */
                    if let pictureUrls = linkedInProfileModel?.profilePicture.displayImage.elements[2].identifiers[0].identifier {
                        linkedinProfilePic = pictureUrls
                    } else {
                        linkedinProfilePic = "Not exists"
                    }
                    print("LinkedIn Profile Avatar URL: \(linkedinProfilePic ?? "")")

                    // Get user's email address
                    self.fetchLinkedInEmailAddress(accessToken: accessToken)
                }
            }
            task.resume()
        }

    private func fetchLinkedInEmailAddress(accessToken: String) {
            let tokenURLFull = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))&oauth2_access_token=\(accessToken)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let verify: NSURL = NSURL(string: tokenURLFull!)!
            let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error == nil {
                    let linkedInEmailModel = try? JSONDecoder().decode(LinkedInEmailModel.self, from: data!)

                    // LinkedIn Email
                    let linkedinEmail: String! = linkedInEmailModel?.elements[0].elementHandle.emailAddress
                    print("LinkedIn Email: \(linkedinEmail ?? "")")

                    DispatchQueue.main.async {
                        self.presentingViewController?.performSegue(withIdentifier: "detailseg", sender: self)
                    }
                }
            }
            task.resume()
        }

}

extension LinkedInService: WKNavigationDelegate{
 
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        RequestForCallbackURL(request: navigationAction.request)
        
        //Close the View Controller after getting the authorization code
        if let urlStr = navigationAction.request.url?.absoluteString {
            if urlStr.contains("?code=") {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        decisionHandler(.allow)
    }

    func RequestForCallbackURL(request: URLRequest) {
        // Get the authorization code string after the '?code=' and before '&state='
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(LinkedInConstants.redirect_url) {
            if requestURLString.contains("?code=") {
                if let range = requestURLString.range(of: "=") {
                    let linkedinCode = requestURLString[range.upperBound...]
                    if let range = linkedinCode.range(of: "&state=") {
                        let linkedinCodeFinal = linkedinCode[..<range.lowerBound]
                        handleAuth(linkedInAuthorizationCode: String(linkedinCodeFinal))
                    }
                }
            }
        }
    }

    func handleAuth(linkedInAuthorizationCode: String) {
        linkedinRequestForAccessToken(authCode: linkedInAuthorizationCode)
    }

    func linkedinRequestForAccessToken(authCode: String) {
        let grantType = "authorization_code"

        // Set the POST parameters.
        let postParams = "grant_type=" + grantType + "&code=" + authCode + "&redirect_uri=" + LinkedInConstants.redirect_url + "&client_id=" + LinkedInConstants.clientID + "&client_secret=" + LinkedInConstants.clientSecret
        let postData = postParams.data(using: String.Encoding.utf8)
        let request = NSMutableURLRequest(url: URL(string: LinkedInConstants.tokenURL)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                let results = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]

                let accessToken = results?["access_token"] as! String
                print("accessToken is: \(accessToken)")

                let expiresIn = results?["expires_in"] as! Int
                print("expires in: \(expiresIn)")

                // Get user's id, first name, last name, profile pic url
                self.fetchLinkedInUserProfile(accessToken: accessToken)
            }
        }
        task.resume()
    }
    
}
