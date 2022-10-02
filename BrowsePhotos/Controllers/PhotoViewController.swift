//
//  PhotoViewController.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import UIKit
import Alamofire
import SDWebImage
import CoreLocation
import Localize_Swift


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
    
    // is photos nearme
    var isNearby: Bool = false

    
    // photo count
    var newObjectsCount: Int = 0
    
    // flicker photos array
    var photosArray: [Photo]!
    
    //location manager for user's current location
    var locationManager = CLLocationManager()
    var currentlocation:CLLocation!
    
    // sheet for language switching
    var actionSheet: UIAlertController!
    // available localizable languages
    let availableLanguages = Localize.availableLanguages()
    
    

    @IBAction func localizeButtonTapped(_ sender: Any) {
        
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertController.Style.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            if displayName == "" {
                continue
            }
            
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                    Localize.setCurrentLanguage(language)
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func photosNearMeButtonTapped(_ sender: Any) {
        
        // photos near me is true
        isNearby = true
        
        //removing current search result
        newObjectsCount = 0
        photosResponse = nil
        photosArray = [Photo]()
        photoCollectionView.reloadData()
        
        // making new api call with latitude and longitude
        fetchAllPhotos()
    }
    
    func authorizelocationstates(){
         if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways {
             currentlocation = locationManager.location
             print(currentlocation)
         }
         else{
             // Note : This function is overlap permission
             //  locationManager.requestWhenInUseAuthorization()
            //  authorizelocationstates()
         }
     }
    
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
        
        
        // for getting user's current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
          // Get Location Permission one time only
        locationManager.requestWhenInUseAuthorization()
          // Need to update location and get location data in locationManager object with delegate
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        // set title for buttons used for localization
        self.setText()
        
        
        
     }
    
    
    // Add an observer for LCLLanguageChangeNotification on viewWillAppear. This is posted whenever a language changes and allows the viewcontroller to make the necessary UI updated. Very useful for places in your app when a language change might happen.
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
        }
    
    // Remove the LCLLanguageChangeNotification on viewWillDisappear
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           NotificationCenter.default.removeObserver(self)
       }
    
    // MARK: Localized Text
        
        @objc func setText(){
            localizeButton.setTitle("Localize".localized(using: "Localizable"), for: UIControl.State.normal)
            photosNearMeButton.setTitle("Photos Near Me".localized(using: "Localizable"), for: UIControl.State.normal)
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
        
        var imageUrlString: String
        
        if isNearby { // photos nearme using user's current latitude and longitude
            imageUrlString = String(format: "%@&page=%d&lat=%@&lon=%@", ServerConfig.imageSearchUrl, currentPage,String(currentlocation.coordinate.latitude),String(currentlocation.coordinate.longitude))

        }else {
            // searching photos by user's provided string
           imageUrlString = String(format: "%@&page=%d&text=%@", ServerConfig.imageSearchUrl, currentPage, searchBar.text!)
        }
        
        // url encoding for dealing space between words in url
        let urlString: String = imageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        // api calling using alamofire
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
        
        // photos nearme is off
        isNearby = false

        
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
        
        // loading selected photo
        let photoObject: Photo = photosArray[indexPath.row]
        
        // main storyboard file
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // loading photo detail viewcontroller from storyboard with identifier
        let photoDetailViewController = storyboard.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
        
        // passing selected photo from gallery to detail view controller
        photoDetailViewController.photo = photoObject
        
        // pushing view controller on navigation
        self.navigationController?.pushViewController(photoDetailViewController, animated: false)
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



extension PhotoViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager = manager
        // Only called when variable have location data
        authorizelocationstates()
    }
}
