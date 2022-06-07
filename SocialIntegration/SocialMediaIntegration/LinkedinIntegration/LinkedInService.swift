//
//  LinkedInService.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 31/05/22.
//


import UIKit
import WebKit

//MARK: Social Media Services for LinkedIn Account
class LinkedInService: NSObject, ISocialService{
    static let shared = LinkedInService()
    private var presentingViewController: UIViewController?
    private var completionHandler: ((UserModel?, SocialMediaServiceError?) -> Void)?
    let classTitle = "LinkedIn"
    
    private override init(){
        super.init()
    }
    
    func login(fromViewController viewController: UIViewController, completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        self.presentingViewController = viewController
        clearCookie()
        let linkedInVC = UIViewController()
        let webView = popUpViewControllerWebView(linkedInVC: linkedInVC)

        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        let authURLFull = LinkedInConstants.authURL + "?response_type=code&client_id=" + LinkedInConstants.clientID + "&scope=" + LinkedInConstants.scope + "&state=" + state + "&redirect_uri=" + LinkedInConstants.redirect_url

        let urlRequest = URLRequest.init(url: URL(string: authURLFull)!)
        webView.load(urlRequest)

        let navController = popUpViewControllerInNavigationController(presentingViewController: viewController, linkedInVC: linkedInVC)
        viewController.present(navController, animated: true, completion: nil)
        self.completionHandler = completion
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
    
    @objc private func cancelAction() {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }

    @objc private func refreshAction() {
            (self.presentingViewController as? ViewController)?.webView.reload()
    }
    
    func logout() {
        clearCookie()
    }
    
    func fetchUserInfo(completion: @escaping (UserModel?, SocialMediaServiceError?) -> Void) {
        if let userAccessToken = self.userAccessToken(){
            self.fetchLinkedInUserProfile(accessToken: userAccessToken, completion: completion)
        }
        else{
            completion(nil, .sessionExpired)
        }
    }
    
    func userAccessToken() -> String?{
        var didSignIn: String?
        if let url = URL(string: LinkedInConstants.redirect_url){
            let urlRequest = URLRequest(url: url)
            self.RequestForCallbackURL(request: urlRequest) { code in
                if let code = code {
                    self.linkedinRequestForAccessToken(authCode: code) { accessToken in
                        if let accessToken = accessToken {
                            didSignIn = accessToken
                        }
                    }
                }
            }
        }
        return didSignIn
    }
    
    private func fetchLinkedInUserProfile(accessToken: String, completion: @escaping(UserModel?, SocialMediaServiceError?) -> Void) {
            let tokenURLFull = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))&oauth2_access_token=\(accessToken)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let verify: NSURL = NSURL(string: tokenURLFull!)!
            let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error == nil {
                    guard data != nil else{ return }
                    let linkedInProfileModel = try? JSONDecoder().decode(LinkedInProfileModel.self, from: data!)
                    
                    // LinkedIn Id
                    let linkedinId: String! = linkedInProfileModel?.id

                    // LinkedIn First Name
                    let linkedinFirstName: String? = linkedInProfileModel?.firstName?.localized?.enUS

                    // LinkedIn Last Name
                    let linkedinLastName: String? = linkedInProfileModel?.lastName?.localized?.enUS

                    // LinkedIn Profile Picture URL
                    var linkedinProfilePic: String?

                    if let pictureUrls = linkedInProfileModel?.profilePicture?.displayImage?.elements[2].identifiers[0].identifier {
                        linkedinProfilePic = pictureUrls
                    }

                    // Get user's email address
                    self.fetchLinkedInEmailAddress(accessToken: accessToken){
                        email in
                        let userModel = UserModel(id: linkedinId, firstName: linkedinFirstName, lastName: linkedinLastName, email: email, mobileNo: nil, profileImageURL: linkedinProfilePic)
                        completion(userModel, nil)
                    }
                }
                completion(nil, .loginFailed)
            }
            task.resume()
        }

    private func fetchLinkedInEmailAddress(accessToken: String, completion: @escaping(String?) -> Void) {
            var linkedinEmail: String?
            let tokenURLFull = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))&oauth2_access_token=\(accessToken)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let verify: NSURL = NSURL(string: tokenURLFull!)!
            let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error == nil {
                    let linkedInEmailModel = try? JSONDecoder().decode(LinkedInEmailModel.self, from: data!)

                    // LinkedIn Email
                    linkedinEmail = linkedInEmailModel?.elements[0].elementHandle?.emailAddress
                    completion(linkedinEmail)
                }
            }
            task.resume()
        }

}

extension LinkedInService: WKNavigationDelegate{
 
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        RequestForCallbackURL(request: navigationAction.request) { linkedInCode in
            if let linkedInCode = linkedInCode {
                self.handleAuth(linkedInAuthorizationCode: linkedInCode)
            }
        }
        
        //Close the View Controller after getting the authorization code
        if let urlStr = navigationAction.request.url?.absoluteString {
            if urlStr.contains("?code=") {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        decisionHandler(.allow)
    }

    private func RequestForCallbackURL(request: URLRequest, completion: @escaping(String?)->Void) {
        // Get the authorization code string after the '?code=' and before '&state='
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(LinkedInConstants.redirect_url) {
            if requestURLString.contains("?code=") {
                if let range = requestURLString.range(of: "=") {
                    let linkedinCode = requestURLString[range.upperBound...]
                    if let range = linkedinCode.range(of: "&state=") {
                        let linkedinCodeFinal = linkedinCode[..<range.lowerBound]
//                        handleAuth(linkedInAuthorizationCode: String(linkedinCodeFinal))
                        completion("\(linkedinCodeFinal)")
                    }
                }
            }
        }
        completion(nil)
    }
    
    

    private func handleAuth(linkedInAuthorizationCode: String){
        self.linkedinRequestForAccessToken(authCode: linkedInAuthorizationCode) { accessToken in
            if let accessToken = accessToken {
                self.fetchLinkedInUserProfile(accessToken: accessToken) { userModel, error in
                    guard self.completionHandler != nil else{ return }
                    self.completionHandler!(userModel, error)
                }
            }
            else{
                self.completionHandler!(nil, .sessionExpired)
            }
        }
    }

    private func linkedinRequestForAccessToken(authCode: String, completion: @escaping(String?) -> Void){
        var accessToken: String?
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

                accessToken = results?["access_token"] as? String

//                let expiresIn = results?["expires_in"] as! Int

//                // Get user's id, first name, last name, profile pic url
                guard accessToken != nil else {
                    return
                }
                completion(accessToken)
//                self.fetchLinkedInUserProfile(accessToken: accessToken)
            }
        }
        task.resume()
    }
    
}
