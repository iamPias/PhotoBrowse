//
//  PhotoViewController.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import UIKit
import Alamofire


class PhotoViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var localizeButton: UIButton!
    
    @IBOutlet weak var photosNearMeButton: UIButton!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var flowLayout:UICollectionViewFlowLayout! = nil
    
    
    // main response from api
    var photosResponse: PhotoResponse!
    
    // detecting is network call is in progress or not
    var isRequestInProgress: Bool = false
    
    // photo count
    var newObjectsCount: Int = 0
    
    // flicker photos array
    var photosArray: [Photo]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SearchBar Delegate
        searchBar.delegate = self
        
        // CollectionView Data Source and Delegate Methods
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        // CollectionView Flow layout added
        flowLayout = UICollectionViewFlowLayout()
        let itemWidth = UIScreen.main.bounds.size.width/3 - 1
        flowLayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1
        photoCollectionView.collectionViewLayout = flowLayout
     }
    
    
    func fetchAllPhotos(){
        
        fetchAllFlickerPhotos { (response, error) in
            if (error != nil){
                  print("error signing in")
              }
              else{
                  print("successful")
                  weak var weakSelf = self
                  self.newObjectsCount = response!.photos.photo.count
                  if weakSelf?.photosResponse != nil {
                      weakSelf?.photosResponse.photos.page = response!.photos.page
                      weakSelf?.photosResponse.photos.pages = response!.photos.pages
                      weakSelf?.photosResponse.photos.perpage = response!.photos.perpage
                      weakSelf?.photosResponse.photos.total = response!.photos.total
                      weakSelf?.photosResponse.photos.photo.append(contentsOf: response!.photos.photo)
                      weakSelf?.photosResponse.stat = response!.stat
                      DispatchQueue.main.async {
                          weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                          weakSelf?.reloadCollectionViewData()

                      }
                  }else{
                      weakSelf?.photosResponse = response
                      weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                      DispatchQueue.main.async {
                          weakSelf?.photoCollectionView.reloadData()
                          weakSelf?.isRequestInProgress = false

                      }
                  }
                  
              }
        }

    }

    
    func fetchAllFlickerPhotos(completion:@escaping (_ responses:PhotoResponse?, _ error:Error?) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let currentPage = newObjectsCount < Constants.per_page - 2 ? 1 : photosResponse.photos.page + 1
        
        var imageUrlString: String =  String(format: "%@&page=%d&text=%@", ServerConfig.imageSearchUrl, currentPage, searchBar.text!)
        
        let urlString: String = imageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        
        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: PhotoResponse.self) {
              response in

              switch response.result {
              case .success(let data):
                  print(data)
                  completion(data,nil)
              case .failure(let error):
                  print(error)
                  completion(nil,error)

              }

          }

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

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = UIScreen.main.bounds.size.width/3 - 1
        return CGSize.init(width: itemWidth, height: itemWidth)    }
    
}
