//
//  NBWUploadImageCollectionViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/10/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "ImageCollectionCell"

struct ImageWithTage {
    var image:UIImage?
    var tag = false
}

protocol SendImageToStatusVCDelegate{
    func sendImageToStatusVC(imageArray:[UIImage])
}

class NBWUploadImageCollectionViewController: UICollectionViewController {
    
    let collectionLayout = UICollectionViewFlowLayout()
    var assets = [PHAsset]()
    var itemSideLength:CGFloat?
    var rightButton:UIButton?
    var delegate:CloseSelfOpenNewViewControllerDelegate?
    var imageDelegate:SendImageToStatusVCDelegate?

    var imageArray = [ImageWithTage]()
    
    init(){
        super.init(collectionViewLayout: collectionLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView?.registerNib(UINib(nibName: "NBWUploadImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.whiteColor()
        setupNavigationBar()
        
        configureCollectionViewLayout()
        
        fetchPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar(){
        navigationItem.title = "Photos"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("dismissSelf:"))
        
        let rightBarButtonContextView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        rightButton = UIButton(frame: rightBarButtonContextView.frame)
        rightButton!.setImage(UIImage(named: "grayNext"), forState: .Normal)
        rightButton!.addTarget(self, action: Selector("nextToUploadImage:"), forControlEvents: .TouchUpInside)
        rightBarButtonContextView.addSubview(rightButton!)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButtonContextView)
        navigationItem.rightBarButtonItem?.enabled = false
        
        navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
    }
    
    func configureCollectionViewLayout(){
        itemSideLength = ((collectionView?.frame.width)! - 16)/3
        collectionLayout.itemSize = CGSize(width: itemSideLength!, height: itemSideLength!)
        collectionLayout.minimumInteritemSpacing = 8
        collectionLayout.minimumLineSpacing = 8
    }
    
    func fetchPhoto(){
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        
        for var i = 0 ; i < smartAlbums.count; i++ {
            let collection = smartAlbums[i]
            if collection.isKindOfClass(PHAssetCollection.classForCoder()){
                let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection as! PHAssetCollection, options: nil)
                for var j = 0; j < fetchResult.count; j++ {
                    let asset = fetchResult[j]
                    if asset.isKindOfClass(PHAsset.classForCoder()) {
                        assets.append(asset as! PHAsset)
                    }
                }
                
            }else{
                assert(false, "Fetch collection not PHCollection: \(collection)")
            }
        }

        imageArray = []
        
        let manager = PHImageManager()
        let imageRequestOptions = PHImageRequestOptions.init()
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
        for asset in assets {
             manager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.Default, options: imageRequestOptions, resultHandler: { (image, dict) -> Void in
                let imageStruct = ImageWithTage(image: image, tag: false)
                self.imageArray.append(imageStruct)
                self.collectionView?.reloadData()
             })
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageArray.count + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NBWUploadImageCollectionViewCell
        
        
        // Configure the cell
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "photoToUpload")
        }else{
            cell.imageView.image = imageArray[indexPath.row - 1].image
            cell.circleTag = UIImageView(frame: CGRect(x: cell.frame.width - 28, y: 8, width: 20, height: 20))
            cell.circleTag!.image = UIImage(named: "circle")
            cell.imageView.addSubview(cell.circleTag!)
        }

        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            let imagePicker = UIImagePickerController.init()
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                imagePicker.sourceType = .Camera
            }else{
                imagePicker.sourceType = .PhotoLibrary
            }
            
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }else{
            if imageArray[indexPath.row - 1].tag {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as!NBWUploadImageCollectionViewCell
                cell.circleTag!.image = UIImage(named: "circle")
                cell.selectedBool = !cell.selectedBool
                imageArray[indexPath.row - 1].tag = !imageArray[indexPath.row - 1].tag
            }else{
                //check the number of images  < 6
                var flagCount = true
                var count = 0
                for imageStruct in imageArray {
                    if imageStruct.tag == true {
                        count++
                    }
                    if count >= 6 {
                        flagCount = false
                    }
                }
                
                //If the number of images < 6
                if flagCount {
                    let cell = collectionView.cellForItemAtIndexPath(indexPath) as!NBWUploadImageCollectionViewCell
                    if cell.selectedBool == false {
                        cell.circleTag!.image = UIImage(named: "orangeCircle")
                    }else{
                        cell.circleTag!.image = UIImage(named: "circle")
                    }
                    
                    cell.selectedBool = !cell.selectedBool
                    imageArray[indexPath.row - 1].tag = !imageArray[indexPath.row - 1].tag
                }
            }
            
            //Check Next Button State
            var flag = false
            for imageStruct in imageArray {
                if imageStruct.tag {
                    flag = true
                }
            }
            
            if flag {
                rightButton?.setImage(UIImage(named: "orangeNext"), forState: .Normal)
                navigationItem.rightBarButtonItem?.enabled = true
            }else{
                rightButton?.setImage(UIImage(named: "grayNext"), forState: .Normal)
                navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }
    
    //MARK: - UIbutton & UIBarButton
    
    func dismissSelf(sender:AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func nextToUploadImage(sender:AnyObject){
        
        var array = [UIImage]()
        
        for imageStruct in imageArray {
            if imageStruct.tag {
                array.append(imageStruct.image!)
            }
        }
        
        delegate?.closeSelfOpenNewVC(composeOptions.updateStatusVC, array)
        imageDelegate?.sendImageToStatusVC(array)
    }
}

//MARK: - Delegate

extension NBWUploadImageCollectionViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let tempImageStruct = ImageWithTage.init(image: image, tag: false)
        imageArray.append(tempImageStruct)
    
        dismissViewControllerAnimated(true) { () -> Void in
            self.collectionView?.reloadData()
        }
    }
}
