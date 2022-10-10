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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var dataController: DataController!
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        setupFetchResultsController()
        getPinsFromStore()
        retrieveZoom()

    }
    
    //MARK: CoreData fetch requests
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "pin")
        
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
            //print(coordinate)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            pins.append(annotation)
        }
        
        mapView.addAnnotations(pins)
    }
    
    //retrieves zoom levels from UserDefaults
    func retrieveZoom() {
        let coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitude"), longitude: UserDefaults.standard.double(forKey: "longitude"))
        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longitudeDelta"))
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
        
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
            let pin = Pin(context: context)
            pin.latitude = latitude
            pin.longitude = longitude
            try? context.save()
            
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
        let pin = Pin(context: context)
        pin.latitude = (view.annotation?.coordinate.latitude)!
        pin.longitude = (view.annotation?.coordinate.longitude)!
        
        performSegue(withIdentifier: "segueToPhotos", sender: pin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoExplorerView {
            let controller = segue.destination as? PhotoExplorerView
            controller?.dataController = dataController
            controller?.selectedPin = sender as? Pin
        }
    }
    
    //saves zoom settings to UserDefaults
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }

}

