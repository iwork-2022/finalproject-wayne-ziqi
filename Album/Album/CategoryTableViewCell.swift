//
//  CategoryTableViewCell.swift
//  Album
//
//  Created by ziqi on 2022/12/17.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var image3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImages(image1:UIImage?, image2:UIImage?, image3:UIImage?){
        if let image1 = image1{
            self.image1.image = image1
        }
        if let image2 = image2{
            self.image2.image = image2
        }
        if let image3 = image3{
            self.image3.image = image3
        }
    }
    
    func setCategoryName(name:String){
        self.categoryName.text = name
    }
    
    static func nib() -> UINib{
        return UINib(nibName: "CategoryTableViewCell", bundle: nil)
    }
}
