//
//  ViewController.swift
//  MyUpload
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/18.
//  See LICENSE.txt .
//

import UIKit
import MobileCoreServices
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // change this to your testing host.
    let SERVER_URL = "http://localhost/uploadtest.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        var sentImage: UIImage
        if let image = info[UIImagePickerControllerEditedImage] as! UIImage? {
            sentImage = image
        } else {
            sentImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        self.postImage(SERVER_URL, image: sentImage) {succeeded, msg in
            print(msg)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func postImage(url : String, image: UIImage, completionHandler: ((succeeded: Bool, msg: String) -> ())?) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        
        let multipart = OOPFormMultipart()
        multipart.add(300_000, name: "MAX_FILE_SIZE") // for php servers.
        multipart.add("ooper-shlab", name: "name")
        multipart.addImageAsJPEG(image, name: "image", filename: "image.jpg")
        request.setMultipart(multipart)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if (error == nil) {
                let msg = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
                completionHandler?(succeeded: true, msg: msg)
            } else {
                completionHandler?(succeeded: false, msg: error!.description)
            }
        }
        task!.resume()
        
    }
}

