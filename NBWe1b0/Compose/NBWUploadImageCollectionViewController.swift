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

class NBWUploadImageCollectionViewController: UICollectionViewController {
    
    let collectionLayout = UICollectionViewFlowLayout()
    var assets = [PHAsset]()
    var itemSideLength:CGFloat?
    
    var imageArray = [UIImage]()
    
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
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        configureCollectionViewLayout()
        
        fetchPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCollectionViewLayout(){
        itemSideLength = (view.frame.width - 16)/3
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
                print(fetchResult.count)
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
        
        print(assets.count)
        
        let manager = PHImageManager()
        for asset in assets {
             manager.requestImageForAsset(asset, targetSize: CGSize(width: itemSideLength!, height: itemSideLength!), contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: { (image, dict) -> Void in
                self.imageArray.append(image!)
                self.collectionView?.reloadData()
             })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemSideLength!, height: itemSideLength!))
        imageView.image = imageArray[indexPath.row]
        cell.contentView.addSubview(imageView)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
