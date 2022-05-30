//
//  SecondViewcontroller.swift
//  SocialIntegration
//
//  Created by neosoft on 25/05/22.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileNoLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        let notKnown = "N/A"
        firstNameLabel.text = "Firstname: \(userModel?.firstName ?? notKnown)"
        lastNameLabel.text = "Lastname: \(userModel?.lastName ?? notKnown)"
        emailLabel.text = "Email: \(userModel?.email ?? notKnown)"
        mobileNoLabel.text = "Mobile No.: \(userModel?.mobileNo ?? notKnown)"
        idLabel.text = "ID: \(userModel?.id ?? notKnown)"
        
//        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.borderColor = UIColor.systemIndigo.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.clipsToBounds = true
    }
}
