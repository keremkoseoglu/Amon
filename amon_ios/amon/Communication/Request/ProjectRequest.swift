//
//  ProjectRequest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 13.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

/*
Steps to add a new functionality here:
Similar steps as described in DroneRequest
*/

import Foundation
import UIKit
import amongst

protocol ProjectRequestClient: CommunicationRequestClient {
	func abortComplete(success:Bool, error:String)
	func getDroneListComplete(list:[String], success:Bool, error:String)
	func refreshComplete(success:Bool, error:String)
	func setupDronesComplete(success:Bool, error:String)
	func startComplete(success:Bool, error:String)
}

struct ProjectRequest: CommunicationRequest {
	
	enum RequestType: String {
		case abort = "AB"
		case undefined = "UD"
		case getDroneList = "GDL"
		case refresh = "REF"
		case setupDrones = "SD"
		case start = "ST"
	}
	
	var project: Project
	var requestID: String
	var requestType: String
	var clients: [CommunicationRequestClient]
	
	init(pType:String, pClients: [ProjectRequestClient], pRequestID: String = "", pProject: Project) {
		requestType = pType
		clients = pClients
		requestID = pRequestID
		project = pProject
	}
	
}

class ProjectRequestManager: CommunicationRequestManager, Caller {
	
	private static var singleton: ProjectRequestManager!
	
	////////////////////////////////////////////////////////////
	// Constructors
	////////////////////////////////////////////////////////////
	
	static func getInstance() -> ProjectRequestManager {
		if singleton == nil {singleton = ProjectRequestManager()}
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Queue processing
	////////////////////////////////////////////////////////////
	
	override internal func processRequest(_ request: CommunicationRequest) {
		guard let projectRequest = request as? ProjectRequest else {
			assertionFailure("Unexpected request type")
			return
		}
		
		let communicator = CommunicatorFactory.getCommunicator()
		
		switch projectRequest.requestType {
		case ProjectRequest.RequestType.abort.rawValue:
			communicator.abortProject(project: projectRequest.project, caller: self)
		case ProjectRequest.RequestType.getDroneList.rawValue:
			communicator.getDroneList(self)
		case ProjectRequest.RequestType.setupDrones.rawValue:
			communicator.setupProject(project: projectRequest.project, caller: self)
		case ProjectRequest.RequestType.start.rawValue:
			communicator.startProject(project: projectRequest.project, caller: self)
		case ProjectRequest.RequestType.refresh.rawValue:
			communicator.refreshProject(project: projectRequest.project, caller: self)
		default:
			assertionFailure("Unsupported project request: " + request.requestType)
		}
	}
	
	////////////////////////////////////////////////////////////
	// Queue processing
	////////////////////////////////////////////////////////////
	
	func abortProjectCompleted(result: CommunicatorResult) {
		for client in getProjectRequestClients() { client.abortComplete(success: result.success, error: result.error) }
		skipToNextRequest()
	}
	
	func announcementCompleted(result: CommunicatorResult) { assertionFailure("Unsupported functionality") }
	
	func droneListFetched(result: CommunicatorResult, droneList: [String]) {
		for client in getProjectRequestClients() {
			client.getDroneListComplete(
				list: droneList,
				success: result.success,
				error: result.error
			)
		}
		
		skipToNextRequest()
	}
	
	func dronePhotoCompleted(result: CommunicatorResult, photo: UIImage, droneID: String) { assertionFailure("Unsupported functionality") }
	
	func droneStateCompleted(result: CommunicatorResult, droneState: DroneState) { assertionFailure("Unsupported functionality") }
	
	func initCompleted(_ result: CommunicatorResult) {
		for client in getProjectRequestClients() {
			client.setupDronesComplete(success: result.success, error: result.error)
		}
		skipToNextRequest()
	}
	
	func refreshProjectCompleted(result: CommunicatorResult) {
		for client in getProjectRequestClients() {
			client.refreshComplete(success: result.success, error: result.error)
		}
		skipToNextRequest()
	}
	
	func setupProjectCompleted(result: CommunicatorResult) {
		for client in getProjectRequestClients() { client.setupDronesComplete(success: result.success, error: result.error) }
		skipToNextRequest()
	}
	
	func startProjectCompleted(result: CommunicatorResult) {
		for client in getProjectRequestClients() { client.startComplete(success: result.success, error: result.error) }
		skipToNextRequest()
	}
	
	func testCompleted(_ result: CommunicatorResult) {
		skipToNextRequest()
	}

	////////////////////////////////////////////////////////////
	// Internal
	////////////////////////////////////////////////////////////
	
	func getProjectRequestClients() -> [ProjectRequestClient] {
		let output = (currentClients as? [ProjectRequestClient])!
		return output
	}
	
}
