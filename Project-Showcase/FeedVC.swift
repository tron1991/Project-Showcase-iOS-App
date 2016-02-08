//
//  FeedVC.swift
//  Project-Showcase
//
//  Created by Nick on 2016-02-07.
//  Copyright © 2016 Nicholas Ivanecky. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    var posts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        
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
        print(post.postDescription)
        
        return tableview.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
    }

}
