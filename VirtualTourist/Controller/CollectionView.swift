//
//  CollectionView.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/22/22.
//

import Foundation
import UIKit
import MapKit

class CollectionView: UIViewController, UICollectionViewDelegate {
    
    // MARK: Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedPin: Pin!
    
    var dataController: DataController!
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
}

extension CollectionView: MKMapViewDelegate {
    
    
    
    
}
