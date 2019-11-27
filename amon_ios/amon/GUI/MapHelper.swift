//
//  MapHelper.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 20.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import MapKit


class MapHelper {
	
	private var annotations: [MKAnnotation]
	
	private var mapView: MKMapView
	
	init(map: MKMapView) {
		mapView = map
		annotations = [MKAnnotation]()
	}
	
	////////////////////////////////////////////////////////////
	// Append annotations
	////////////////////////////////////////////////////////////
	
	func appendAmonLocation(_ location: CLLocation) {
		appendAnnotation(coord: location.coordinate, icon: AmonGui.Icon.amon)
	}
	
	func appendAnnotation(_ annotation: MKAnnotation) {
		annotations.append(annotation)
	}
	
	func appendAnnotation(coord: CLLocationCoordinate2D, icon: AmonGui.Icon, subTitle:String="") {
		
		if coord.latitude == 0 || coord.longitude == 0 {return}
		
		let annotation = MKPointAnnotation()
		
		annotation.coordinate = coord
		
		var title = icon.rawValue
		if subTitle != "" {title += " (" + subTitle + ")"}
		annotation.title = title
		
		appendAnnotation(annotation)
	}
	
	func appendDroneLocation(_ d: Drone, appendBase:Bool=false) {
		appendAnnotation(coord: d.state.coordinate, icon: AmonGui.Icon.drone)
		if appendBase {appendAnnotation(coord: d.state.baseCoordinate, icon: AmonGui.Icon.base)}
	}
	
	////////////////////////////////////////////////////////////
	// General stuff
	////////////////////////////////////////////////////////////
	
	func resetAnnotations() {
		if annotations.count > 0 {
			mapView.removeAnnotations(annotations)
			annotations = [MKAnnotation]()
		}
	}
	
	func setCenter(_ coordinate: CLLocationCoordinate2D) {
		if coordinate.latitude <= 0 {return}
		mapView.setCenter(coordinate, animated: true)
		
		let centerRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
		mapView.setRegion(centerRegion, animated: true)
	}
	
	func showAnnotations(center: CLLocationCoordinate2D?) {
		mapView.addAnnotations(annotations)
		if center != nil { setCenter(center!) }
	}
	
}
