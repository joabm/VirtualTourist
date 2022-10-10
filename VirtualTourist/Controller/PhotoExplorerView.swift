//
//  CollectionView.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/22/22.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoExplorerView: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var selectedPin: Pin!
    
    var dataController: DataController!
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewFlowLayout()
        mapAnnotaion()
        retrievePhotos()
        setupFetchedResultsController()
    }
    
    // MARK: Core Data Fetch
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: MapView
    
    func mapAnnotaion(){
        
        let latitude = selectedPin.latitude
        let longitude = selectedPin.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        centerMapOnLocation(CLLocation(latitude: latitude, longitude: longitude), mapView: mapView)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 20000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: Retrieve URLs and Photos
    
    func retrievePhotos () {
        if selectedPin.photos?.count == 0 {
            getPhotoURL(completion: {
                self.collectionView.reloadData()
                if self.selectedPin.photos?.count == 0 {
                    print("There are not photos in the store for this location.")
                }
            })
        }
    }
    
    func getPhotoURL(completion: @escaping () -> Void) {
        setActivityIndicator(true)
        FlickrClient.getLocationPhotos(latitude: selectedPin.latitude, longitude: selectedPin.longitude) { (data, error) in
            print("getlocationPhotos excecuted")
            if data?.photos.total == 0 {
                self.showFailure(message: "There are no photos at this location.  Zoom in for an accurate location selection.")
            }
            if error == nil {
                for photo in data!.photos.photo {
                    let photoURL = FlickrClient.photoURL(photo: photo)
                    let photo = Photo(context: self.context)
                    photo.url = photoURL
                    photo.pin = self.selectedPin
                    try? self.context.save()
                }
                self.setupFetchedResultsController()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.setActivityIndicator(false)
                }
            } else {
                self.setActivityIndicator(false)
                self.showFailure(message: "\(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    @IBAction func newCollectionButtonTapped(sender: UIButton) {
        print("New Collection tapped")
        newCollectionButton.isEnabled = false
        deleteStorePhotos()
        print(selectedPin.photos?.count as Any)
        //collectionView.reloadData()
        retrievePhotos()
        //collectionView.reloadData()
    }
    
    func deleteStorePhotos() {
        for photo in fetchedResultsController.fetchedObjects! {
            context.delete(photo)
        }
        try? context.save()
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
    }
    
    
    // MARK: Activity Indicator
    
    func setActivityIndicator(_ isFinding: Bool) {
        if isFinding {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: Failure messaging
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Photo Data", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}


    // MARK: Collection View Extension
extension PhotoExplorerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        newCollectionButton.isEnabled = true
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
        let storePhoto = fetchedResultsController.object(at: indexPath) //get any existing photo image from the datastore
        
        if let photo = storePhoto.photo { //if there is already a photo in the store display it
            cell.imageView.image = UIImage(data: photo)
        } else { //otherwise download a photo from Flickr
            if let url = storePhoto.url{
                let photoURL = url
                FlickrClient.getImage(path: URL(string: photoURL)!) { data, error in
                    guard let data = data else {
                        return
                    }
                    storePhoto.photo = data
                    storePhoto.pin = self.selectedPin
                    try? self.context.save() // save the image to the store with the pin relationship
                    DispatchQueue.main.async { //display the image on the main thread
                        if let photo = storePhoto.photo {
                            cell.imageView.image = UIImage(data: photo)
                        }
                    }
                }
            }
        }
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storePhoto = fetchedResultsController.object(at: indexPath)
        context.delete(storePhoto)
        try? context.save() //delete the selected photo from the store and save the change
        self.setupFetchedResultsController()
        DispatchQueue.main.async { //delete the selected photo from the collection view and update the view data
            collectionView.deleteItems(at: [indexPath])
            collectionView.reloadData()
        }
    }
    
    // MARK: FlowLayout
    
    func collectionViewFlowLayout() {
        let space: CGFloat = 8.0
        let dimension = (view.frame.size.width - (4 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
}
