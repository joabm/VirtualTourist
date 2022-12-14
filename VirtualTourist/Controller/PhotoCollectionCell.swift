//
//  PhotoCollectionCell.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 10/1/22.
//

import Foundation
import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
