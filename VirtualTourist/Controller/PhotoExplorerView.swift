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
    
    var locationPhotos = [UIImage]()
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        mapAnnotaion()
        getLocationPhotos()
        //print(FlickrClient.Endpoint.queryPhotosList(selectedPin.latitude, selectedPin.longitude).url)
        
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
    
    // MARK: Retrieve Photos
    
    func getLocationPhotos() {
        FlickrClient.getLocationPhotos(latitude: selectedPin.latitude, longitude: selectedPin.longitude, completion: handleLocationPhotosListResponse(location:error:))
    }
    
    func handleLocationPhotosListResponse(location: [Photos], error: Error?) {
        if error == nil {
            print("you have data")
        } else {
            showFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    
    
    
    
    
    
    // MARK: Failure messaging
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Photo data error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

    // MARK: Collection View
extension PhotoExplorerView: UICollectionViewDelegate, UICollectionViewDataSource {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if locationPhotos.count == 0 {
            return 30
        } else  {
            return locationPhotos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        newCollectionButton.isEnabled = true
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
//        if locationPhotos.count > 0 {
//            DispatchQueue.main.async {
//                cell?.cell
//            }
//        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO Code for deleting photo from collection
    }
    
}
