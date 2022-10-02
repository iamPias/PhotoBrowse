//
//  PhotoDetailViewController.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import UIKit
import SDWebImage

class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // image url
        let imageUrlString = String(format: "https://farm%d.static.flickr.com/%@/%@_%@.jpg", photo.farm, photo.server, photo.id, photo.secret)
        
        // loading image with sdwebimage
        photoImageView.sd_setImage(with: URL(string:imageUrlString ), placeholderImage: UIImage(named: "placeholder.png"))
        //image title
        photoTitleLabel.text = photo.title

    }
    

}
