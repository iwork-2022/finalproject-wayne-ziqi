//
//  CategoryCollectionViewController.swift
//  Album
//
//  Created by ziqi on 2022/12/17.
//

import UIKit

private let reuseIdentifier = "PhotoCollectionViewCell"

class CategoryCollectionViewController: UICollectionViewController {
    
    var categoryName:String?
    
    var photoSequnce:[PhotoDescriptor]?
    
    let photoManager = PhotoManager.photoManager
    
    let dbHelper = DataBaseHelper.dbHelper
    
    
    @IBOutlet weak var cateNavi: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width / 6, height: view.frame.size.height / 5)
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(PhotoCollectionViewCell.nib(), forCellWithReuseIdentifier: reuseIdentifier)
        
        photoManager.managerDelegateCate = self
        
        photoSequnce = photoManager.album[self.categoryName!]

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photoSequnce?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        let photo = photoSequnce?[indexPath.row]
        if let photo = photo{
            cell.configure(with: dbHelper.data2image(data: photo.image!) , named: photo.photoName!)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoSequnce![indexPath.row]
        performSegue(withIdentifier: "categoryShowPhoto", sender: photo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedItem = sender as? PhotoDescriptor else{
            return
        }
        if segue.identifier == "categoryShowPhoto"{
            guard let destVC = segue.destination as? PhotoViewController else{
                return
            }
            destVC.photo = selectedItem
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension CategoryCollectionViewController:PhotoManagerDelegate{
    func updateContent() {
        self.photoSequnce = photoManager.album[self.categoryName!]
        self.collectionView.reloadData()
    }
}
