//
//  LogInViewController.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 19/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController,UINavigationControllerDelegate {
    
    var messageController:MessagesController?
    
    var inputViewHeightAnchor:NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor:NSLayoutConstraint?
    
    let inputContainerView: UIView = {
        let inputView = UIView()
        inputView.backgroundColor = UIColor.white
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.layer.cornerRadius = 5
        inputView.clipsToBounds = true
        
        return inputView
    }()
    
    let registerButton:UIButton = {
        let registerBtn = UIButton(type: .system)
        registerBtn.backgroundColor = ColorConstants.KRegisterButtonColor
        registerBtn.setTitleColor(UIColor.white, for: .normal)
        registerBtn.setTitle("Register", for: .normal)
        registerBtn.layer.cornerRadius = 4
        registerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        registerBtn.clipsToBounds = true
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        
        return registerBtn
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let nameLineView:UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = ColorConstants.KLineViewColor
        
        return line
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let emailLineView:UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = ColorConstants.KLineViewColor
        
        return line
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
        
    }()
    
    let segmentView: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Login","Register"])
        segment.tintColor = UIColor.white
        segment.selectedSegmentIndex = 1
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(segmentButtonTapped), for: .valueChanged)
        
        return segment
    }()

    lazy var profileImageView: UIImageView = {
        let pI = UIImageView()
        pI.image = #imageLiteral(resourceName: "imageIcon")
        pI.contentMode = .scaleAspectFill
        pI.isUserInteractionEnabled = true
        pI.layer.cornerRadius = pI.frame.size.height/2
        pI.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        pI.translatesAutoresizingMaskIntoConstraints = false
        
        return pI
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConstants.KLoginScreenColor
        view.addSubview(inputContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        view.addSubview(segmentView)
        
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameLineView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailLineView)
        inputContainerView.addSubview(passwordTextField)
        
        
        inputContainerViewConstraints()
        setRegisterButtonConstraints()
        setProfileImageConstraint()
        setSegmentViewConstraint()
        
    }
    
    override public  var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension LogInViewController {
    
    func inputContainerViewConstraints() {
        // Constraints for this view:-
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputViewHeightAnchor?.isActive = true
        
        // Constraints for NameTextField:-
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // Constraints for NamelineView:-
        nameLineView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameLineView.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        nameLineView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Constraints for EmailTextField:-
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // Constraints for EmailineView:-
        emailLineView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailLineView.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        emailLineView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Constraints for PasswordTextField:-
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    func setRegisterButtonConstraints(){
        // Constraints for this view:-
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func setProfileImageConstraint(){
        // Constraint of this image view:-
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: segmentView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    func setSegmentViewConstraint(){
        // Constraint of this image view:-
        segmentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        segmentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        segmentView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }

}

extension LogInViewController {
    
    @objc func handleLoginOrRegister(){
        if segmentView.selectedSegmentIndex == 0 {
            loginButtonTapped()
        } else {
            registerButtonTapped()
        }
    }
    
    func loginButtonTapped() {
        guard let email = emailTextField.text , let password = passwordTextField.text else {
            print("wrong format")
            return
        }
        Auth.auth().signInAndRetrieveData(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!)
                return
            }
            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func registerButtonTapped(){
        guard let email = emailTextField.text , let password = passwordTextField.text, let name = nameTextField.text else {
            print("Wrong format")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user:User?, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            let imageName = NSUUID().uuidString
            let storageReference = Storage.storage().reference().child("profile_Image").child("\(imageName).jpg")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage,0.1) {
                storageReference.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let profileImageUrl = metaData?.downloadURL()?.absoluteString {
                        let values = ["name":name,"email":email,"profileImageURL":profileImageUrl] as [String : Any]
                        self.registerUserIntoDatabase(uid: uid, values: values)
                    }
                })
            }
        }
    }
    
    private func registerUserIntoDatabase(uid:String,values:[String:Any]){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userRefrence = ref.child("Users").child(uid)
        userRefrence.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }

            let user = Users()
            user.name = values["name"] as? String
            user.profileImage = values["profileImageURL"] as? String
            self.messageController?.setUpNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func segmentButtonTapped() {
        let title = segmentView.titleForSegment(at: segmentView.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        inputViewHeightAnchor?.constant = segmentView.selectedSegmentIndex == 0 ? 100 : 150
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier:segmentView.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier:segmentView.selectedSegmentIndex == 0 ? 1/2: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier:segmentView.selectedSegmentIndex == 0 ? 1/2: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
}

extension LogInViewController : UIImagePickerControllerDelegate {
    
    @objc func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}






