//
//  AddNewNoticeViewController.swift
//  TeachUs
//
//  Created by ios on 6/2/19.
//  Copyright © 2019 TeachUs. All rights reserved.
//

import UIKit
import FirebaseStorage
import MobileCoreServices

protocol AddNewNoticeDelegate {
    func viewDismissed()
}

class AddNewNoticeViewController: BaseViewController {
    
    @IBOutlet weak var viewAddNoticeWrapper: UIView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var viewTilteBg: UIView!
    @IBOutlet weak var textfieldNoticeTitle: UITextField!
    @IBOutlet weak var viewDescriptionBg: UIView!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var buttonAddNotice: UIButton!
    @IBOutlet weak var labelClassNames: UILabel!
    @IBOutlet weak var buttonSelectClass: UIButton!
    @IBOutlet weak var buttonPreviewNotice: UIButton!
    
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    var documentPicker:UIDocumentPickerViewController!
    var chosenFile:URL?
    var chosenImage:UIImage?
    var viewClassList : ViewClassSelection!
    let storage = Storage.storage()
    var delegate:AddNewNoticeDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewNoticeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewNoticeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.initClassSelectionView()
        imagePicker?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewAddNoticeWrapper.makeEdgesRounded()
        self.viewDescriptionBg.makeEdgesRounded()
        self.viewTilteBg.makeEdgesRounded()
        self.buttonPreviewNotice.roundedRedButton()
    }
    
    func initClassSelectionView(){
        self.viewClassList = ViewClassSelection.instanceFromNib() as? ViewClassSelection
        self.viewClassList.delegate = self
    }
    
    @IBAction func acctionDissmissView(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.delegate != nil{
                self.delegate.viewDismissed()
            }
        })
    }
    
    @IBAction func actionUploadNotice(_ sender: Any) {
        self.uploadFileToFirebase(completion: { (fileURL, fileSize, fileName)  in
            LoadingActivityHUD.showProgressHUD(view: UIApplication.shared.keyWindow!)
            let manager = NetworkHandler()
            manager.url = URLConstants.CollegeURL.collegeUploadNotice
            let parameters = [
                "college_code":"\(UserManager.sharedUserManager.appUserCollegeDetails.college_code!)",
                "class_id":"\(CollegeClassManager.sharedManager.getSelectedClassList)",
                "title":self.textfieldNoticeTitle.text ?? "",
                "description":"\(self.textViewDescription.text ?? "")",
                "doc":fileURL.absoluteString,
                "file_name":"\(fileName)",
                "role_id":"1,2,3",
                "doc_size":"\(fileSize)"
            ]
            manager.apiPost(apiName: "Upload nOtes", parameters:parameters, completionHandler: { (result, code, response) in
                if let status = response["status"] as? Int, status == 200, let message = response["message"] as? String{
                    self.showAlterWithTitle("Success", alertMessage: message)
                    self.chosenImage = nil
                    self.chosenFile = nil
                }
                self.acctionDissmissView(self)
                LoadingActivityHUD.hideProgressHUD()
            }) { (error, code, message) in
                print(message)
                LoadingActivityHUD.hideProgressHUD()
            }
        }) { (errorMessage) in
            self.showAlterWithTitle("Error", alertMessage: errorMessage)
        }
    }
    
    @IBAction func actionShowClassList(_ sender: Any) {
        if (CollegeClassManager.sharedManager.selectedClassArray.count > 0){
            self.viewClassList.frame = CGRect(x: 0.0, y: 0.0, width: self.view.width(), height: self.view.height())
            self.view.addSubview(self.viewClassList)
        }
    }
    
    @IBAction func actionUploadDocument(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Notes", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        let documentAction = UIAlertAction(title: "Document", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openDocumentPicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.addAction(documentAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker!.sourceType = UIImagePickerControllerSourceType.camera
            self .present(imagePicker!, animated: true, completion: nil)
        }else{
            self.showAlterWithTitle("Oops!", alertMessage: "Camera Access Not Provided")
            
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker!, animated: true, completion: nil)
        }else{
            self.showAlterWithTitle("Oops!", alertMessage: "Photo Library Access Not Provided")
        }
    }
    
    func openDocumentPicker(){
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeItem]
        self.documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(self.documentPicker, animated: true, completion: nil)
    }
    
    func uploadFileToFirebase(completion:@escaping(_ fileUrl:URL, _ filesize:String,_ fileName:String) -> Void,
                              failure:@escaping(_ message:String) -> Void){
        LoadingActivityHUD.showProgressHUD(view: UIApplication.shared.keyWindow!)
        
        if let mobilenumber = UserManager.sharedUserManager.appUserDetails.contact{
            
            let storageRef = storage.reference()
            let filePathReference = storageRef.child("\(mobilenumber)/Notice/")
            if let selectedImage = self.chosenImage,let jpedData = UIImageJPEGRepresentation(selectedImage, 1){
                let fileNameRef = filePathReference.child("\(Int64(Date().timeIntervalSince1970 * 1000)).jpg")
                let uploadTask = fileNameRef.putData(jpedData, metadata: nil) { (metadata, error) in
                    LoadingActivityHUD.hideProgressHUD()
                    fileNameRef.downloadURL { (url, error) in
                        guard let metadata = metadata else {
                            failure("Unable to upload")
                            return
                        }
                        guard let downloadURL = url else {
                            failure("Unable to upload")
                            return
                        }
                        completion(downloadURL,"\(metadata.size)",fileNameRef.name)
                    }
                }
                uploadTask.observe(.progress) { snapshot in
                    // A progress event occured
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    print("\(percentComplete)% uploaded ")
                }
            }
            
            if let selectedFile = self.chosenFile{
                let fileNameRef = filePathReference.child("\(selectedFile.lastPathComponent)")
                let uploadTask = fileNameRef.putFile(from: selectedFile, metadata: nil) { metadata, error in
                    LoadingActivityHUD.hideProgressHUD()
                    fileNameRef.downloadURL { (url, error) in
                        guard let metadata = metadata else {
                            failure("Unable to upload")
                            return
                        }
                        guard let downloadURL = url else {
                            failure("Unable to upload")
                            return
                        }
                        
                        if let errorObject = error {
                            print("errorObject \(errorObject.localizedDescription)")
                            failure("Unable to upload")
                        }
                        completion(downloadURL, "\(metadata.size)", fileNameRef.name)
                    }
                }
                uploadTask.observe(.progress) { snapshot in
                    // A progress event occured
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    print("\(percentComplete)% uploaded ")
                }
            }
        }
    }
}


extension AddNewNoticeViewController{
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size{
            if(self.viewAddNoticeWrapper != nil){
                if((self.buttonPreviewNotice.origin().y + self.viewAddNoticeWrapper.origin().y) >= (self.view.height()-keyboardSize.height) && self.view.frame.origin.y == 0)
                {
                    self.view.frame.origin.y -= keyboardSize.height/2
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}


extension AddNewNoticeViewController:UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        self.chosenFile = myURL
        self.chosenImage = nil
        print("import result : \(myURL)")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.chosenFile = url
        self.chosenImage = nil
        print("import result : \(url)")

    }
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        self.documentPicker.dismiss(animated: true, completion: nil)
    }
}

extension AddNewNoticeViewController:ViewClassSelectionDelegate{
    func classViewDismissed() {
        self.viewClassList.removeFromSuperview()
        print("class dismissed")
    }
}


extension AddNewNoticeViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.chosenImage = image
            self.chosenFile = nil
        }
        
        if let videoURL = info["UIImagePickerControllerMediaURL"] as? URL{
            print("videoURL \(videoURL)")
            
            var fileAttributes: [FileAttributeKey : Any]? = nil
            do {
                fileAttributes = try FileManager.default.attributesOfItem(atPath: videoURL.path)
            } catch let attributesError {
                print(attributesError.localizedDescription)
            }
            let fileSizeNumber = fileAttributes?[.size] as? NSNumber
            let fileSize: Int64 = fileSizeNumber?.int64Value ?? 0
            if fileSize > 26214400{
                self.showAlterWithTitle("ERROR", alertMessage: "File size should be less than 25mb")
            }else{
                self.chosenFile = videoURL
            }
            print(String(format: "SIZE OF VIDEO: %0.2f Mb", Float(fileSize) / 1024 / 1024))
        }
        
        imagePicker?.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: true, completion: nil)
    }
}
