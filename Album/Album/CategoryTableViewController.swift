//
//  CategoryTableViewController.swift
//  Album
//
//  Created by ziqi on 2022/12/17.
//

import UIKit

private let reuseIdentifier = "CategoryTableViewCell"

class CategoryTableViewController: UITableViewController {
    
    let photoManager = PhotoManager.photoManager
    
    let dbHelper = DataBaseHelper.dbHelper

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(CategoryTableViewCell.nib(), forCellReuseIdentifier: reuseIdentifier)
        photoManager.managerDelegateCateTab = self
        photoManager.getAllPhotos()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return photoManager.categoryNum
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CategoryTableViewCell

        // Configure the cell...
        cell.categoryName.text = photoManager.categorySequence[indexPath.row]
        let category:[PhotoDescriptor] = photoManager.album[cell.categoryName.text!]!
        
        var i = 0
        for photo in category{
            if i == 0{
                cell.image1.image = dbHelper.data2image(data: photo.image!)
            }else if i == 1{
                cell.image2.image = dbHelper.data2image(data: photo.image!)
            }else if i == 2{
                cell.image3.image = dbHelper.data2image(data: photo.image!)
            }else{
                break
            }
            i += 1
        }
        if i == 0{
            cell.image1.image = nil
            cell.image2.image = nil
            cell.image3.image = nil
        }else if i == 1{
            cell.image2.image = nil
            cell.image3.image = nil
        }else if i == 2{
            cell.image3.image = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPhotosInCategory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CategoryCollectionViewController{
            let cateName = photoManager.categorySequence[(tableView.indexPathForSelectedRow?.row)!]
            dest.categoryName = cateName
            dest.cateNavi.title = cateName
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CategoryTableViewController:PhotoManagerDelegate{
    func updateContent() {
        self.tableView.reloadData()
    }
}
