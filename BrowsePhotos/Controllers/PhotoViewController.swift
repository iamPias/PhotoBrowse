//
//  PhotoViewController.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var localizeButton: UIButton!
    
    @IBOutlet weak var photosNearMeButton: UIButton!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SearchBar Delegate
        searchBar.delegate = self
        
        // CollectionView Data Source and Delegate Methods
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
     }

}

extension PhotoViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // On Tap Cancel keyboard will dismiss
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // On Tap SearchButton keyboard will dismiss
        searchBar.resignFirstResponder()

    }
}



extension PhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {

    }

}


extension PhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
}
