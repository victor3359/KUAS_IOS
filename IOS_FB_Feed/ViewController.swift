//
//  ViewController.swift
//  IOS_FB_Feed
//
//  Created by Liu Jun Wei on 2016/10/30.
//  Copyright © 2016年 Liu Jun Wei. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import Social

let cellId = "cellId"


class Posts: NSObject
{
    var name: String?
    var time: String?
    var profileImageName: String?
    var statusText: String?
    var statusImageName: String?
    var numOflikes: NSNumber?
    var numOfComments: NSNumber?
    var numOfShares: NSNumber?
    var shareURL: String?
}

class ShareButton: UIButton
{
    var URL: URL?
}


class FeedController: UICollectionViewController , UICollectionViewDelegateFlowLayout, FBSDKLoginButtonDelegate{
    
    var posts = [Posts]()
    
    let loginButton : FBSDKLoginButton = {
    let button = FBSDKLoginButton()
    button.readPermissions = ["public_profile","email","user_friends"]
    return button
    }()
    
    /*let likebutton: FBSDKLikeButton = {
        let button = FBSDKLikeButton()
        button.objectID = "https://www.facebook.com/1413402935650513_1417529638571176"
        return button
    }()*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 66, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        
        view.addSubview(collectionView!)
        
        collectionView?.addSubview(loginButton)
        
        loginButton.frame = CGRect(x:16,y:8,width:view.frame.width - 32,height:50)
        loginButton.delegate = self
        
        
        if (FBSDKAccessToken.current()) != nil{
            fetchFanPage()
        }
        
        fetchFanPage()
        
        //Add to Array
        
        navigationItem.title = "KUAS IOS_Facebook"
        
        collectionView?.backgroundColor = UIColor(white:0.95,alpha:1)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        
        //viewDidLoad End
    }
    
    
    //撈取粉絲專頁的資料
    
    func fetchFanPage(){
        //let Token = FBSDKAccessToken.current().tokenString
        let Token = "EAAa2ZBnr08RMBAJcd6ms4kC0HgfOY4kVuye71VUw6oT0gJaD2QnFZBczrGfC484CnKoZBo1WP6sSWfCJ8KNMJCyHmbgHqJWXWv9zB4jSGRfx4lrhVD8gxdB4R2hDDwHADsobS4HiwKmq1sECGreM6L1e8g6E3gZD"
        
        let urlToken = "https://graph.facebook.com/496974947026732/posts?fields=id,shares,permalink_url,comments.limit(0).summary(true),story,created_time,full_picture,message,likes.limit(0).summary(true)&access_token=\(Token)"
        
        let url = URL(string: urlToken)
        
        
        URLSession.shared.dataTask(with: url!) { (data, response, error)  in
            if error != nil{
                print(error!)
                return
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
                self.posts = [Posts]()

                if let dictionary = json as? [String: AnyObject]{
                    for data in dictionary["data"] as! [[String: AnyObject]]{
                        let datapost = Posts()
                        datapost.name = "TAT Taiwan"
                        if let likes = data["likes"] as? [String: AnyObject]{
                            if let summary = likes["summary"] as? [String: AnyObject]{
                                datapost.numOflikes = summary["total_count"] as! NSNumber?
                            }
                        }
                        if let shares = data["shares"] as? [String: AnyObject]{
                                datapost.numOfShares = shares["count"] as! NSNumber?
                        }
                        if let comments = data["comments"] as? [String: AnyObject]{
                            if let summary = comments["summary"] as? [String: AnyObject]{
                                datapost.numOfComments = summary["total_count"] as! NSNumber?
                            }
                        }
                        datapost.shareURL = data["permalink_url"] as! String?
                        datapost.statusText = data["message"] as! String?
                        datapost.statusImageName = data["full_picture"] as! String?
                        datapost.time = data["created_time"] as! String?
                        datapost.profileImageName = "TAT Taiwan"
                        self.posts.append(datapost)
                    }
                }
                self.collectionView?.reloadData()
                
            }catch let JsonError{
                print(JsonError)
            }
        }.resume()
    }
    
    

    
    
    //Fetch Facebook Profile Data
    /*
    func fetchProfile() {
        print("fetch Profile")
        
        let Newpost = Posts()
        
        let parameters = ["fields":"posts{message}"]
        
        FBSDKGraphRequest(graphPath: "1413402935650513", parameters: parameters).start { (connection, result, error) in
            
            if error != nil {
                
                print("logged in error =\(error)")
                
            } else {
                
                //解包
                if let resultNew = result as? [String: AnyObject] {
                    
                    if let post = resultNew["posts"] as? [String: AnyObject] {
                        
                        if let datasArray = post["data"] as? [[String: AnyObject]] {
                            /*self.posts = [Posts]()
                            
                            for postDictionary in datasArray{
                                let post = Posts()
                                post.statusText = postDictionary[
                                self.posts.append(post)
                            }*/
                            print(datasArray[0]["message"]!)
                        }
                    }
                }
            }
        }
    }*/
    
        func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
            print("completed login")
            if error != nil {
                print(error)
                return
            }
            print("successfully logged in with facebook")
            fetchFanPage()
        }
        
        func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
            print("Did log out of facebook")
    }
        
        func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
            return true
        }
        
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //CollectionView的個數
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedcell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedcell.post = posts[indexPath.item]
        return feedcell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //隱藏多餘文字區塊
        if let statusText = posts[indexPath.item].statusText{
            let rect  = NSString(string: statusText).boundingRect(with: CGSize(width: view.frame.width, height: 1000) , options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            
            
        //補回應有高度
            
            let knownHeight : CGFloat = 8+44+4+4+200+8+24+8
            return CGSize(width: view.frame.width, height: rect.height+knownHeight+24   )
        }
        
        
        return CGSize(width: view.frame.width, height: 500)
    }
    
    //切換直向橫向
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //ShareAction
    func shareAction(sender: ShareButton){
        let ActivityViewController = UIActivityViewController(activityItems: [sender.URL!], applicationActivities: nil)
        self.present(ActivityViewController, animated: true, completion: nil)
        print("URL is \(sender.URL!)")
 
    }
    
    //class FeedView End
}

    class FeedCell: UICollectionViewCell{
        
        
        var post: Posts? {
            didSet {
                //ProfileName
                if let name = post?.name{
                    if let time = post?.time{
                    let attributedText = NSMutableAttributedString(string: name , attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 16)])
                    //DateString Processing
                    //Start
                    let datestring = (time as NSString).substring(to: 10)
                    let hourstring = (time as NSString).substring(with: NSMakeRange(11, 2))
                    let timestring = (time as NSString).substring(with: NSMakeRange(13, 6))
                    var hour = (hourstring as NSString).integerValue + 8
                    let timeString: String?
                        if hour > 23{
                            hour = hour - 24
                        }
                        if hour < 10{
                            timeString = "0\(hour)\(timestring)"
                        }else {
                            timeString = "\(hour)\(timestring)"
                        }
                    let TimeString = "\(datestring)     \(timeString!)"
                    //End
                    attributedText.append(NSAttributedString(string: "\n\(TimeString)", attributes:[NSFontAttributeName:UIFont.systemFont(ofSize:12), NSForegroundColorAttributeName:UIColor.gray]))
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4
                    
                    attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
                    
                    nameLabel.attributedText = attributedText
                    }
                }
                //PostText
                if let statusText = post?.statusText{
                    statusTextView.text = statusText

                }
                //ProfilePicture
                if let profileImageName = post?.profileImageName{
                    profileImageView.image = UIImage(named: profileImageName)
                    
                }
                //PostPicture
                if let statusImageName = post?.statusImageName{
                    if let url = NSURL(string: statusImageName){
                        if let data = NSData(contentsOf: url as URL){
                            statusImageView.image = UIImage(data: data as Data)
                        }
                    }
                }
                //Count Of Likes, Comments, Shares
                if let numOfLikes = post?.numOflikes {
                    likesLabel.text = "\(numOfLikes)個讚"
                      
                }
                
                let numOfShares = post?.numOfShares
                
                    if numOfShares != nil {
                        sharesLabel.text = "\(numOfShares!)個分享"
                    }else{
                        sharesLabel.text = "0個分享"
                    }
                
                
                //SharePost's URL
                let shareURL = post?.shareURL
                shareButton.URL = URL(string: shareURL!)
                //shareButton.URL = shareURL
                shareButton.addTarget(nil , action: #selector(FeedController.shareAction(sender:)), for: .touchUpInside)
                
            }
        }
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupViews()
        }
        
        required init?(coder aDecoder:NSCoder){
            fatalError("init(coder:) has not been implemented")
        }
        
        //Label
        let nameLabel : UILabel = {
            let label = UILabel()
            label.numberOfLines = 2
            return label
        }()
        
    
        
//宣告元件區
        
        //ImageView
        let profileImageView : UIImageView = {
            let ImageView = UIImageView()
            ImageView.contentMode = .scaleAspectFit
            return ImageView
        }()
        
        
        //statusTextView
        let statusTextView : UITextView = {
            let textView = UITextView()
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.isEditable = false
            textView.isScrollEnabled = false
            return textView
        }()
        
        //statusImageView
        let statusImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "TAT Taiwan")
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            return imageView
        }()
        
        let likesLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = UIColor.gray
            return label
        }()
        
        let sharesLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = UIColor.gray
            return label
        }()
        
        let dividerLineView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.gray
            return view
        }()

        //SetButton Function   FBShare Button
        let shareButton: ShareButton = {
            let button = ShareButton()
            /*button.setTitle("Share", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)*/
            //button.setImage(UIImage(named: "shareIcon"), for: .normal)
            button.setBackgroundImage(UIImage(named: "shareIcon"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            return button
        }()
        //let likeButton = FBSDKLikeButton()
        
//宣告元件尾端
        
        func setupViews(){
            backgroundColor = UIColor.white
            
            //AddSubView
            addSubview(nameLabel)
            addSubview(profileImageView)
            addSubview(statusTextView)
            addSubview(statusImageView)
            addSubview(likesLabel)
            addSubview(sharesLabel)
            addSubview(dividerLineView)
            addSubview(shareButton)
            //addSubview(likeButton)
            
            //AddConStraints
            addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
            addConstraintsWithFormat(format: "H:|[v0]|", views: statusImageView)
            addConstraintsWithFormat(format: "H:|-12-[v0][v1]-12-|", views: likesLabel,sharesLabel)
            addConstraintsWithFormat(format: "H:|-12-[v0]-12-|", views: dividerLineView)
            addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]-8-[v2(24)]-18-|", views: profileImageView,nameLabel,shareButton)
            //addConstraintsWithFormat(format: "V:|-12-[v0]", views: likeButton)
            addConstraintsWithFormat(format: "V:|-12-[v0]", views: nameLabel)
            addConstraintsWithFormat(format: "V:|-18-[v0(24)]", views: shareButton)
            addConstraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2(200)]-8-[v3(24)]-8-[v4(0.4)]|", views: profileImageView,statusTextView,statusImageView,likesLabel,dividerLineView)
            addConstraintsWithFormat(format: "V:[v0(24)]-8-|", views: sharesLabel)

        }
    }


extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView{
    func addConstraintsWithFormat(format:String,views:UIView...){
        var viewsDictionary = [String:UIView]()
        for(index, view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}









