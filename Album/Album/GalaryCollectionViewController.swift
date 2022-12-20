//
//  GalaryCollectionViewController.swift
//  Album
//
//  Created by ziqi on 2022/12/12.
//

import UIKit

private let reuseIdentifier = "PhotoCollectionViewCell"

class GalaryCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var importButton: UIBarButtonItem!
    
    let photoManager = PhotoManager.photoManager
    
    let dbHelper = DataBaseHelper.dbHelper
    
    func importMenuItems()->UIMenu{
        let menu = UIMenu(title: "Import From...", options: .displayInline, children: [
            UIAction(title: "Camera",image: UIImage(systemName: "camera"), handler: {_ in
                self.presentPhotoPicker(sourceType: .camera)
            }),
            UIAction(title: "Album",image: UIImage(systemName: "photo.on.rectangle"), handler:{_ in
                self.presentPhotoPicker(sourceType: .photoLibrary)
            })
        ])
        return menu
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func storeImage(image:UIImage){
        // print("image will be stored")
        photoManager.addPhoto(image: image, name: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        
        //        let layout = UICollectionViewFlowLayout()
        //        layout.itemSize = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>
        //
        //        collectionView.collectionViewLayout = layout
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width / 6, height: view.frame.size.height / 5)
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(PhotoCollectionViewCell.nib(), forCellWithReuseIdentifier: reuseIdentifier)
        
        importButton.menu = importMenuItems()
        
        photoManager.managerDelegateGalary = self
        
        // Do any additional setup after loading the view.
        // load photos from core data
        photoManager.getAllPhotos()
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
        return photoManager.albumSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        // Configure the cell
        let photo = photoManager.albumSequence[indexPath.row]
        cell.configure(with: dbHelper.data2image(data: photo.image!) , named: photo.photoName!)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoManager.albumSequence[indexPath.row]
        performSegue(withIdentifier: "galaryShowPhoto", sender: photo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedItem = sender as? PhotoDescriptor else{
            return
        }
        if segue.identifier == "galaryShowPhoto"{
            guard let destVC = segue.destination as? PhotoViewController else{
                return
            }
            destVC.photo = selectedItem
        }
    }

    
    
    
    
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

extension GalaryCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        
        storeImage(image: image)
//        classify(image: image)
    }
}

extension GalaryCollectionViewController:PhotoManagerDelegate{
    func updateContent() {
        self.collectionView.reloadData()
    }
}
