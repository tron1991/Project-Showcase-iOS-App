//
//  FeedVC.swift
//  Project-Showcase
//
//  Created by Nick on 2016-02-07.
//  Copyright © 2016 Nicholas Ivanecky. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    var posts = [Post]()
    
    @IBOutlet weak var imageSelected: UIImageView!
    var imageSel : Bool!
    var imagePicker: UIImagePickerController!
    
    static var imageCache = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.estimatedRowHeight = 350
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        //DOWNLOAD DATA FROM FIREBASE
        
        //update posts right away
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
           print(snapshot.value)
            
            //clear out when
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postkey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
           self.tableview.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableview.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
               img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150 
        } else {
            return tableview.estimatedRowHeight
        }
    }
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            if let img = imageSelected.image where imageSel == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName:  "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData!, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON!, name: "format")
                    
                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            print("Link: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                            
                        case.Failure(let error):
                            print(error)
                        }
                }
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelected.image = UIImage(named: "camera")
        
        tableview.reloadData()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelected.image = image
        imageSel = true
    }

}
