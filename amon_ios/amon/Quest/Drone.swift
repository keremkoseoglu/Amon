//
//  Drone.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 12.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

/*
Steps to add a new drone communication functionality:
- Add the new functionality to DroneRequest - check the description (comment) there
- Add a new method below (like refreshState)
- Make sure to have a method under output (like refreshStateComplete)
*/

import Foundation
import UIKit
import MapKit
import amongst


class Drone : DroneRequestClient {

	public var state: DroneState
	public var image: UIImage
	
	private static var externalDroneRequestClients = [DroneRequestClient]()
	
	////////////////////////////////////////////////////////////
	// Generic stuff
	////////////////////////////////////////////////////////////
	
	init(_ pState:DroneState) {
		state = pState
		image = UIImage(ciImage: CIImage(color: CIColor.black))
	}
	
	func getCompletionPercentage() -> Int {
		var output: Int = 0
		if state.totalMissionSteps > 0 {
			let f1 = Float(state.completeMissionSteps)
			let f2 = Float(state.totalMissionSteps)
			let f3: Float = f1 / f2
			let f4: Float = f3 * 100
			output = Int(f4)
		}
		return output
	}
	
	static func addExternalDroneRequestClient(_ client: DroneRequestClient) {
		externalDroneRequestClients.append(client)
	}
	
	private func getClients(_ adhocClient: DroneRequestClient) -> [DroneRequestClient] {
		var output = [DroneRequestClient]()
		output.append(self)
		output.append(adhocClient)
		for prc in Drone.externalDroneRequestClients {output.append(prc)}
		return output
	}
	
	////////////////////////////////////////////////////////////
	// Drone Request input
	////////////////////////////////////////////////////////////
	
	func refreshState(client:DroneRequestClient, requestID:String="") {
		
		let request = DroneRequest(
			pType: DroneRequest.RequestType.refreshState.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pDrone: self
		)

		DroneRequestManager.getInstance().addRequest(request)
	}
	
	func shootPhoto(client:DroneRequestClient, requestID:String="") {
		
		let request = DroneRequest(
			pType: DroneRequest.RequestType.shootPhoto.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pDrone: self
		)
		
		DroneRequestManager.getInstance().addRequest(request)
	}
	
	////////////////////////////////////////////////////////////
	// Drone Request output
	////////////////////////////////////////////////////////////
	
	func refreshStateComplete(state: DroneState, success: Bool, error: String) {
		if success {self.state = state} else {self.state.lastInfo = error}
	}
	
	func shootPhotoComplete(droneID: String, image: UIImage, success: Bool, error: String) {
		if success {self.image = image} else {self.state.lastInfo = error}
	}
	
	
}
