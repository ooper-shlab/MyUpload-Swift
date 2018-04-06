//
//  ViewController.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/18.
//  Updated for Swift 3 on 2016/12/29.
//  See LICENSE.txt .
//

import UIKit
import MobileCoreServices
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*
     * This sample code is setting `NSAllowsArbitraryLoads` (Allow Arbitrary Loads) to `YES` in Info.plist,
     * which, in actual apps, you should not.
     */
    // change this to your testing host.
    let SERVER_URL = "http://localhost/uploadtest.php"

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(_: AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    @IBAction func sendText(_ sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        self.postText(SERVER_URL, params: ["username": username, "password": password]) {succeeded, msg in
            print(msg)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var sentImage: UIImage
        if let image = info[UIImagePickerControllerEditedImage] as! UIImage? {
            sentImage = image
        } else {
            sentImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        self.postImage(SERVER_URL, image: sentImage) {succeeded, msg in
            print(msg)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func postImage(_ url : String, image: UIImage, completionHandler: @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        let multipart = OOPFormMultipart()
        multipart.add(300_000, name: "MAX_FILE_SIZE") // for php servers.
        multipart.add("ooper-shlab", name: "name")
        multipart.add(image, format: .jpeg, name: "image", filename: "image.jpg")
        request.set(multipart)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request) {data, response, error in
            if let error = error {
                completionHandler(false, error.localizedDescription)
            } else {
                let msg = data.flatMap{String(data: $0, encoding: .utf8)} ?? ""
                completionHandler(true, msg)
            }
        }
        task.resume()
    }
    func postText(_ url : String, params: [String: String], completionHandler: @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        let urlencoded = OOPFormUrlencoded()
        for (key, value) in params {
            urlencoded[key] = value
        }
        request.set(urlencoded)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request) {data, response, error in
            if let error = error {
                completionHandler(false, error.localizedDescription)
            } else {
                let msg = data.flatMap{String(data: $0, encoding: .utf8)} ?? ""
                completionHandler(true, msg)
            }
        }
        task.resume()
    }
}

