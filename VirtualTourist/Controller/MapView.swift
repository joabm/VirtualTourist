//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/21/22.
//

import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    var pins: [Pin] = []
    
    var dataController:DataController!
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: Actions


}

