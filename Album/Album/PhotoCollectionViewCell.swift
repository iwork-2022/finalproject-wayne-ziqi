//
//  PhotoCollectionViewCell.swift
//  Album
//
//  Created by ziqi on 2022/12/12.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image:UIImage, named name:String){
        imageView.image = image
        let ratio = self.frame.height / self.frame.width
        let newHeight = imageView.frame.width * ratio
        imageView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
    }
    
    static func nib() -> UINib{
        return UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
    }

}
