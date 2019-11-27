//
//  DroneRequest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 12.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

/*
Steps to add a new functionality here:
- Add the new func to Communicator (check the commentary in Communicator.swift)
- Add a new funcComplete to DroneRequestClient (+ where used list)
- Add a new TYPE_ to DroneRequest
- Add the new functionality to processRequest
*/

import Foundation
import UIKit
import amongst

protocol DroneRequestClient: CommunicationRequestClient {
	func refreshStateComplete(state:DroneState, success:Bool, error:String)
	func shootPhotoComplete(droneID: String, image: UIImage, success:Bool, error:String)
}

struct DroneRequest: CommunicationRequest {

	enum RequestType:String {
		case undefined = "UD"
		case refreshState = "RS"
		case shootPhoto = "SP"
	}
	
	var drone: Drone
	var requestID: String
	var requestType: String
	var clients: [CommunicationRequestClient]
	
	init(pType:String, pClients: [DroneRequestClient], pRequestID: String = "", pDrone: Drone) {
		requestType = pType
		clients = pClients
		requestID = pRequestID
		drone = pDrone
	}
	
}

class DroneRequestManager: CommunicationRequestManager, Caller {
	
	private static var singleton: DroneRequestManager!
	
	////////////////////////////////////////////////////////////
	// Constructors
	////////////////////////////////////////////////////////////
	
	static func getInstance() -> DroneRequestManager {
		if singleton == nil {singleton = DroneRequestManager()}
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Queue processing
	////////////////////////////////////////////////////////////

	override internal func processRequest(_ request: CommunicationRequest) {
		guard let droneRequest = request as? DroneRequest else {
			assertionFailure("Unexpected request type")
			return
		}
		
		switch droneRequest.requestType {
		case DroneRequest.RequestType.refreshState.rawValue:
			CommunicatorFactory.getCommunicator().getDroneState(
				droneID: droneRequest.drone.state.name,
				caller: self
			)
		case DroneRequest.RequestType.shootPhoto.rawValue:
			CommunicatorFactory.getCommunicator().getDronePhoto(
				droneID: droneRequest.drone.state.name,
				caller: self
			)
		default:
			assertionFailure("Unsupported drone request: " + request.requestType)
		}
	}
	
	////////////////////////////////////////////////////////////
	// Queue processing
	////////////////////////////////////////////////////////////
	
	func abortProjectCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }

	func announcementCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func droneListFetched(result: CommunicatorResult, droneList: [String]) { assertionFailure("Unsupported functionality") }
	
	func droneStateCompleted(result: CommunicatorResult, droneState: DroneState) {
		for droneClient in getDroneRequestClients() {
			droneClient.refreshStateComplete(
				state: droneState,
				success:result.success,
				error: result.error
			)
		}
		
		skipToNextRequest()
	}
	
	func dronePhotoCompleted(result: CommunicatorResult, photo: UIImage, droneID: String) {
		for droneClient in getDroneRequestClients() {
			droneClient.shootPhotoComplete(
				droneID: droneID,
				image: photo,
				success: result.success,
				error: result.error
			)
		}
		
		skipToNextRequest()
	}
	
	func initCompleted(_ result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func refreshProjectCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func setupProjectCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func startProjectCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func testCompleted(_ result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	////////////////////////////////////////////////////////////
	// Internal
	////////////////////////////////////////////////////////////
	
	func getDroneRequestClients() -> [DroneRequestClient] {
		let output = (currentClients as? [DroneRequestClient])!
		return output
	}
	
}
