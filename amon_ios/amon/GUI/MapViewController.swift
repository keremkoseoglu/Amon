//
//  SecondViewController.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 10.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit
import MapKit
import EasyLocation
import EasyGUI
import EasyTelegram

class MapViewController: UIViewController, ProjectRequestClient, LocationClient {
	
	@IBOutlet weak var mapView: MKMapView!
	
	private var amonLocation: CLLocation!
	private var mapHelper: MapHelper!
	private var spinner: UIView!
	private var project: Project!
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if mapHelper == nil {mapHelper = MapHelper(map: mapView)}
	}
	
	////////////////////////////////////////////////////////////
	// User interaction
	////////////////////////////////////////////////////////////
	
	@IBAction func refreshClick(_ sender: Any) {
		
		spinner = Gui.showSpinner(onView: self.view)
		
		do {
			project = try Project.getCurrentProject()
		}
		catch {
			Gui.hideSpinner(spinner)
			Gui.showToast(controller: self, message: error.localizedDescription)
			return
		}
		
		project.refresh(client: self)
	}
	
	////////////////////////////////////////////////////////////
	// Project Request Client
	////////////////////////////////////////////////////////////
	
	func abortComplete(success: Bool, error: String) {}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {}
	
	func refreshComplete(success: Bool, error: String) {
		if !success { DispatchQueue.main.async {Gui.showToast(controller: self, message: error) }}
		Location.getInstance().requestLocation(client: self, timeOut: Double(Settings.getTelegramSettings().telegramTimeout))
	}
	
	func setupDronesComplete(success: Bool, error: String) {}
	
	func startComplete(success: Bool, error: String) {}
	
	////////////////////////////////////////////////////////////
	// Location Client
	////////////////////////////////////////////////////////////
	
	func addressDetected(address: String, success: Bool, error: String) {}
	
	func locationDetected(location: CLLocation?, success: Bool, error: String) {
		DispatchQueue.main.async {
			Gui.hideSpinner(self.spinner)
			
			if success {self.amonLocation = location} else {
				self.amonLocation = nil
				Gui.showToast(controller: self, message: error)
			}
			self.paintCoordsToMap()
			self.centerMapToFirstAvailableLocation()
		}
	}
	
	////////////////////////////////////////////////////////////
	// Self
	////////////////////////////////////////////////////////////
	
	private func centerMapToFirstAvailableLocation() {
		for projectDrone in project.getDrones() {
			if projectDrone.drone.state.coordinate.latitude > 0 {
				mapHelper.setCenter(projectDrone.drone.state.coordinate)
				return
			}
		}
	}
	
	private func paintCoordsToMap() {
		mapHelper.resetAnnotations()
		
		for projectDrone in project.getDrones() {
			mapHelper.appendDroneLocation(projectDrone.drone, appendBase: false)
		}
		
		if amonLocation != nil { mapHelper.appendAmonLocation(amonLocation) }
		
		mapHelper.showAnnotations(center:nil)
	}
	
}

