//
//  ViewController.swift
//  TeachUs
//
//  Created by APPLE on 13/10/17.
//  Copyright © 2017 TeachUs. All rights reserved.
//

import UIKit
import ObjectMapper

enum LoginUserType {
    case student
    case professor
    case college
    case parents
    
    var userTypeString:String{
        switch self {
        case .student: return Constants.UserTypeString.Student
        case .professor: return Constants.UserTypeString.Professor
        case .college: return Constants.UserTypeString.College
        case .parents: return Constants.UserTypeString.Parents
            
        }
    }
}

class LoginSelectViewController: BaseViewController {
    var arrayUserRoles:[UserRole] = []
    var userType:LoginUserType!
    var roleStudent:UserRole!
    var roleProfessor:UserRole!
    var roleCollege:UserRole!
    var roleParents:UserRole!
    
    var appUpdateData:AppUpdateData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDefaultBackGroundImage()
        self.navigationController?.navigationBar.isHidden = false

        self.getRoleList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addGradientToNavBar()
        self.addColorToNavBarText(color: UIColor.white)
    }
    
    func getRoleList(){
        let manager = NetworkHandler()
        //http://zilliotech.com/api/teachus/role
        manager.url = URLConstants.Login.role
        LoadingActivityHUD.showProgressHUD(view: UIApplication.shared.keyWindow!)
        manager.apiGet(apiName: "Get Role for all user", completionHandler: { (response, code) in
            LoadingActivityHUD.hideProgressHUD()
            
            /*
            let appUpdateData:[Any] = response["device_update"] as! [Any]
            for update in appUpdateData{
                let tempUpdate :AppUpdateData = Mapper<AppUpdateData>().map(JSONObject: update)!
                if tempUpdate.osType == "IOS"
                {
                    self.appUpdateData = tempUpdate
                }
                self.checkAndShowAppUpdateDialogue()
            }
            */
            let userRoleDict:[Any] = response["roles"] as! [Any]
            for user in userRoleDict{
                let userRoleDict:[String:Any] = user as! [String:Any]
                let userRoleString:String = userRoleDict["role_name"] as! String
                switch userRoleString{
                case "Student":
                    self.roleStudent = Mapper<UserRole>().map(JSONObject: user)!
                    break
                case "Lecturer":
                    self.roleProfessor = Mapper<UserRole>().map(JSONObject: user)!
                    break
                case "College":
                    self.roleCollege = Mapper<UserRole>().map(JSONObject: user)!
                    break
                case "Parents":
                    self.roleParents = Mapper<UserRole>().map(JSONObject: user)!
                default:
                    break
                }
            }
            
            if let contact = response["contact"] as? String,
                let email = response["email"] as? String,
                let body = response["body"] as? String{
                UserManager.sharedUserManager.unauthorisedUser.contact = contact
                UserManager.sharedUserManager.unauthorisedUser.email   = email
                UserManager.sharedUserManager.unauthorisedUser.body    = body
            }
        }) { (error, code, errorMessage) in
            LoadingActivityHUD.hideProgressHUD()
            if(code == Constants.CustomErrorCodes.noInternet){
                
                self.showErrorAlert(.NoInternet, retry: { (retry) in
                    if(retry){
                        self.getRoleList()
                    }
                })
            }
            print(errorMessage)
        }
    }

    @IBAction func loginStudent(_ sender: Any) {
        UserManager.sharedUserManager.setLoginUserType(.student)
        UserManager.sharedUserManager.userRole = roleStudent
        self.performSegue(withIdentifier: Constants.segues.toLoginView, sender: self)
    }
    
    @IBAction func loginProfessor(_ sender: Any) {
        UserManager.sharedUserManager.setLoginUserType(.professor)
        UserManager.sharedUserManager.userRole = roleProfessor
        self.performSegue(withIdentifier: Constants.segues.toLoginView, sender: self)
    }

    @IBAction func loginCollege(_ sender: Any) {
        UserManager.sharedUserManager.setLoginUserType(.college)
        UserManager.sharedUserManager.userRole = roleCollege
        self.performSegue(withIdentifier: Constants.segues.toLoginView, sender: self)
    }
    
    
    @IBAction func loginParents(_ sender:Any){
        UserManager.sharedUserManager.setLoginUserType(.parents)
        UserManager.sharedUserManager.userRole = roleParents
        self.performSegue(withIdentifier: Constants.segues.toLoginView, sender: self)

    }

    func checkAndShowAppUpdateDialogue() {
        if !(self.appUpdateData.isforceUpdate)
        {
            // create the alert
            let alert = UIAlertController(title: "\(self.appUpdateData.forceUpdateTextTitle)", message: "\(self.appUpdateData.forceUpdateText)", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction((UIAlertAction(title: "Go to AppStore", style: .default, handler: { (action) in
                if let url = URL(string: URLConstants.TeachUsAppStoreLink.storeLink) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })))
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "New Version Available!", message: "\(self.appUpdateData.appUpdateText)", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction((UIAlertAction(title: "Go to AppStore", style: .default, handler: { (action) in
                if let url = URL(string: URLConstants.TeachUsAppStoreLink.storeLink) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.toLoginView{
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
            

        }
    }
}

