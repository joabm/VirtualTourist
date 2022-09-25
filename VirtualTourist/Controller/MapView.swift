//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/21/22.
//

import UIKit
import MapKit
import CoreData

class MapView: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties

    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var dataController: DataController!
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        longPressGesture.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressGesture)
        
        setupFetchResultsController()
    }
    
    //MARK: CoreData fetch requests
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Data Error: \(error.localizedDescription)")
        }
    }
    
    //gets saved pins from the store and annotates the map
    func getPinsFromStore () {
        
        var pins: [MKAnnotation] = []
        
        //loops through pins in the store to build the pins array
        for pin in fetchedResultsController.fetchedObjects! {
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            pins.append(annotation)
        }
        
        mapView.addAnnotations(pins)
    }
    
    
    //MARK:  Handle long press on map
    
    @objc func handleLongPress(longPressGesture: UIGestureRecognizer) {
        if longPressGesture.state == .ended {
            //converts the location of a long press on map to coordinate form
            let location = longPressGesture.location(in: mapView)
            let locationCoordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            //extracts coordinate values
            let latitude = locationCoordinates.latitude
            let longitude = locationCoordinates.longitude
            
            //creates a pin and saves it to the store
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = latitude
            pin.longitude = longitude
            try? dataController.viewContext.save()
            
            //adds the pin to the map
            let coordinate  = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    // MARK: - MKMapViewDelegate

    // create pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView

        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.markerTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    //on tap pin select, send latitude and longitude to Collection view on segue
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = (view.annotation?.coordinate.latitude)!
        pin.longitude = (view.annotation?.coordinate.longitude)!
        
        performSegue(withIdentifier: "segueToCollection", sender: pin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CollectionView {
            let controller = segue.destination as? CollectionView
            controller?.dataController = dataController
            controller?.selectedPin = sender as? Pin
        }
    }

}

