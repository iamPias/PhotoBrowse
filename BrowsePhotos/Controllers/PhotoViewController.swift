//
//  PhotoViewController.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import UIKit
import Alamofire
import SDWebImage



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
              }
              else{
                  print("successful")
                  weak var weakSelf = self
                  
                  // photo counting
                  self.newObjectsCount = response!.photos.photo.count
                  if weakSelf?.photosResponse != nil {
                      
                      //flicker photo page number
                      weakSelf?.photosResponse.photos.page = response!.photos.page
                      //flicker total page number
                      weakSelf?.photosResponse.photos.pages = response!.photos.pages
                      //flicker photo loading on each page
                      weakSelf?.photosResponse.photos.perpage = response!.photos.perpage
                      //flicker total photo counting
                      weakSelf?.photosResponse.photos.total = response!.photos.total
                      // appending photo during scrolling
                      weakSelf?.photosResponse.photos.photo.append(contentsOf: response!.photos.photo)
                      // status of flicker photo
                      weakSelf?.photosResponse.stat = response!.stat
                      DispatchQueue.main.async {
                          //photo array from photo response
                          weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                          // reloading collection view
                          weakSelf?.reloadCollectionViewData()

                      }
                  }else{
                      weakSelf?.photosResponse = response
                      weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                      DispatchQueue.main.async {
                          weakSelf?.photoCollectionView.reloadData()
                          // is api request is in progress or not
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
        
        // determinig page number
        let currentPage = newObjectsCount < Constants.per_page - 2 ? 1 : photosResponse.photos.page + 1
        
        var imageUrlString: String =  String(format: "%@&page=%d&text=%@", ServerConfig.imageSearchUrl, currentPage, searchBar.text!)
        
        // url encoding
        let urlString: String = imageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        
        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: PhotoResponse.self) {
              response in

              switch response.result {
              case .success(let data):  // on api response success
                  print(data)
                  completion(data,nil)
              case .failure(let error): // on api response failure
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
        
        //removing current search result
        newObjectsCount = 0
        photosResponse = nil
        photosArray = [Photo]()
        photoCollectionView.reloadData()
        
        // making api call again for new search string
        fetchAllPhotos()

    }
}



extension PhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photosArray else {
            return 0
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // loading collection view cell from storyboard
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        // loading photo object
        let photoObject: Photo = photosArray[indexPath.row]
        
        // flicker image url
        let imageUrlString = String(format: "https://farm%d.static.flickr.com/%@/%@_%@.jpg", photoObject.farm, photoObject.server, photoObject.id, photoObject.secret)
        
        // image caching using sdwebimage
        cell.photoImageView.sd_setImage(with: URL(string:imageUrlString ), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        // progressive api call during photo gallery scrolling
        if isLoadingCell(for: indexPath) && !isRequestInProgress {
            fetchAllPhotos()
        }

    }

}


extension PhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = UIScreen.main.bounds.size.width/3 - 1
        return CGSize.init(width: itemWidth, height: itemWidth)    }
    
}


private extension PhotoViewController {
    
    // is photo collection view cell loading
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= photosResponse.photos.photo.count - 5
    }
    
    // reloading collection view after api  response
    func reloadCollectionViewData() {
        let newIndexPathsToReload = calculateIndexPathsToReload()
        if newIndexPathsToReload.count == 0 {
            photoCollectionView.reloadData()
            return
        }

        self.photoCollectionView.performBatchUpdates({[weak self] in
            self?.photoCollectionView.insertItems(at: newIndexPathsToReload)
        }, completion: {[weak self](success) in
            self?.isRequestInProgress = false
        })
    }
    
    
    // finding visible collection view photo cell
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = photoCollectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    // calculating collectionview indexpath
    private func calculateIndexPathsToReload() -> [IndexPath] {
        let startIndex = photosResponse.photos.photo.count - newObjectsCount
        let endIndex = startIndex + newObjectsCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
