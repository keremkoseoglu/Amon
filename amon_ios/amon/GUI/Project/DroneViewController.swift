//
//  DroneViewController.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 18.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit
import MapKit
import EasyLocation
import EasyGUI
import EasyTelegram
import amongst

class DroneViewController: UIViewController, DroneRequestClient, MKMapViewDelegate, LocationClient {
	
	var projectDrone: ProjectDrone!
	
	private var amonLocation: CLLocation!
	private var spinner: UIView!
	private var droneToAmonDistance: CLLocationDistance!
	private var mapHelper: MapHelper!
	
	@IBOutlet weak var lblStarted: UILabel!
	@IBOutlet weak var lblOccupied: UILabel!
	@IBOutlet weak var lblFinished: UILabel!
	@IBOutlet weak var lblCoords: UILabel!
	@IBOutlet weak var lblHeight: UILabel!
	@IBOutlet weak var lblBaseCoords: UILabel!
	@IBOutlet weak var lblLastInfo: UILabel!
	@IBOutlet weak var lblDistance: UILabel!
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var imgView: UIImageView!
	
	@IBOutlet weak var naviBar: UINavigationItem!
	
	@IBOutlet weak var progMission: UIProgressView!
	@IBOutlet weak var progBattery: UIProgressView!
	
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if mapHelper == nil {mapHelper = MapHelper(map: mapView)}
		if (droneToAmonDistance == nil) {droneToAmonDistance = -1}
		
		paintDroneState()
    }
	
	////////////////////////////////////////////////////////////
	// Own stuff
	////////////////////////////////////////////////////////////
	
	private func getCoordAsText(_ c: CLLocationCoordinate2D) -> String {
		return c.latitude.description + ";" + c.longitude.description
	}
	
	private func paintCoordsToMap() {
		
		// Initialization
		
		mapHelper.resetAnnotations()
		
		let state = projectDrone.drone.state
		
		// Locations
		mapHelper.appendDroneLocation(projectDrone.drone, appendBase: true)
		if amonLocation != nil { mapHelper.appendAmonLocation(amonLocation) }
		
		// Mission
		
		var wpIndex = 0
		var wpIcon = AmonGui.Icon.waypoint_incomplete
		
		for wayPoint in state.mission.waypoints {
			wpIndex += 1
			
			if wpIndex < state.mission.lastCompleteWaypointIndex {
				wpIcon = AmonGui.Icon.waypoint_complete
			}
			else if wpIndex == state.mission.lastCompleteWaypointIndex + 1 {
				wpIcon = AmonGui.Icon.waypoint_working
			}
			else {
				wpIcon = AmonGui.Icon.waypoint_incomplete
			}
			
			mapHelper.appendAnnotation(
				coord: wayPoint,
				icon: wpIcon,
				subTitle: String(wpIndex)
			)

		}
		
		// Flush
		mapHelper.showAnnotations(center:projectDrone.drone.state.coordinate)
	}
	
	private func paintDroneState() {
		let state = projectDrone.drone.state
		
		naviBar.title = state.name
		
		if state.startedMission {
			lblStarted.text = AmonGui.Icon.green.rawValue
		}
		else {
			lblStarted.text = AmonGui.Icon.gray.rawValue
		}
		
		if state.isOccupied {
			lblOccupied.text = AmonGui.Icon.green.rawValue
		}
		else {
			lblOccupied.text = AmonGui.Icon.gray.rawValue
		}
		
		if state.finishedMission {
			lblFinished.text = AmonGui.Icon.green.rawValue
		}
		else {
			lblFinished.text = AmonGui.Icon.gray.rawValue
		}
		
		lblCoords.text = getCoordAsText(state.coordinate)
		lblHeight.text = String(state.height)
		lblBaseCoords.text = getCoordAsText(state.baseCoordinate)
		lblLastInfo.text = state.lastInfo
		
		if droneToAmonDistance > 0 {
			lblDistance.text = String(abs(droneToAmonDistance))
		} else {
			lblDistance.text = "?"
		}
		
		setProgress(progressView: progMission, value: Float(state.completeMissionSteps), maxValue: Float(state.totalMissionSteps))
		setProgress(progressView: progBattery, value: Float(state.batteryPercentage), maxValue: 100)
		
		imgView.image = projectDrone.drone.image
		
		paintCoordsToMap()
	}
	
	private func setProgress(progressView: UIProgressView, value: Float, maxValue: Float) {
		var perc: Float = 0
		if value != 0 && maxValue != 0 { perc = value / maxValue }
		progressView.setProgress(perc, animated: true)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	////////////////////////////////////////////////////////////
	// User commands
	////////////////////////////////////////////////////////////

	@IBAction func doneClick(_ sender: Any) {
		dismiss(animated: true) {
			
		}
	}
	
	@IBAction func refreshClick(_ sender: Any) {
		spinner = Gui.showSpinner(onView: self.view)
		projectDrone.drone.refreshState(client: self)
	}
	
	@IBAction func pictureClick(_ sender: Any) {
		spinner = Gui.showSpinner(onView: self.view)
		projectDrone.drone.shootPhoto(client: self)
	}
	
	////////////////////////////////////////////////////////////
	// Drone State Client
	////////////////////////////////////////////////////////////
	
	func refreshStateComplete(state: DroneState, success: Bool, error: String) {
		
		if success {
			Location.getInstance().requestLocation(client: self, timeOut: Double(Settings.getTelegramSettings().telegramTimeout))
		}
		else {
			Gui.hideSpinner(spinner)
			Gui.showToast(controller: self, message: error)
		}
		
	}
	
	func shootPhotoComplete(droneID: String, image: UIImage, success: Bool, error: String) {
		
		DispatchQueue.main.async {
			Gui.hideSpinner(self.spinner)
			
			if self.projectDrone == nil {return} // Paranoya
			if self.projectDrone.drone.state.name != droneID {return}
			
			if success {
				self.imgView.image = image
			}
			else
			{
				Gui.showToast(controller: self, message: error)
			}
		}
	}

	////////////////////////////////////////////////////////////
	// Location Client
	////////////////////////////////////////////////////////////
	
	func addressDetected(address: String, success: Bool, error: String) {}
	
	func locationDetected(location: CLLocation?, success: Bool, error: String) {
		
		DispatchQueue.main.async {
			Gui.hideSpinner(self.spinner)
			
			if success {
				self.amonLocation = location
				
				let droneCoord = self.projectDrone.drone.state.coordinate
				if droneCoord.latitude > 0 && droneCoord.longitude > 0 {
					self.droneToAmonDistance = self.amonLocation.distance(
						from: CLLocation(
							latitude: droneCoord.latitude,
							longitude: droneCoord.longitude
						)
					)
				}
				else {
					self.droneToAmonDistance = -1
				}
			}
			else {
				self.amonLocation = nil
				self.droneToAmonDistance = -1
				Gui.showToast(controller: self, message: error)
			}
			self.paintDroneState()
		}
	}
	
}

