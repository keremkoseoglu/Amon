//
//  Project.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 12.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

/*
Steps to add a new project communication functionality:
Steps are similar to Drone.swift, check the commentary there
*/

import Foundation
import amongst


class ProjectDrone {
	var drone: Drone
	private var employed: Bool
	private var setupComplete: Bool
	private var setupInfo: String
	
	init(pDrone: Drone) {
		drone = pDrone
		employed = false
		setupComplete = false
		setupInfo = ""
	}
	
	func getSetupInfo() -> String {return setupInfo}
	
	func isEmployed() -> Bool {return employed}
	func isSetupComplete() -> Bool {return setupComplete}
	
	func setEmployed(_ pEmployed: Bool) {
		employed = pEmployed
		setSetupComplete(true) // Employed => Setup zaten complete
	}
	
	func setSetupComplete(_ complete:Bool, info:String="") {
		setupComplete = complete
		setupInfo = info
	}
	
}

class Project : ProjectRequestClient {
	
	enum ProjectError: Error {
		case alreadyRunning
		case droneNotReady(droneName: String)
		case duplicateDrone(droneName: String)
		case invalidDroneIndex
		case noEmployedDrone
		case noProjectInitialized
		case notRunning
		case projectDroneNotFound(droneName: String)
	}
	
	enum ProjectStatus: String {
		case idle = "Idle"
		case ready = "Ready"
		case running = "Running"
	}
	
	private static var singleton: Project!
	private static var externalProjectRequestClients = [ProjectRequestClient]()
	
	var projectID: String
	var isRunning: Bool
	private var drones: [ProjectDrone]
	
	
	////////////////////////////////////////////////////////////
	// Construction
	////////////////////////////////////////////////////////////
	
	private init(id: String) {
		projectID = id
		isRunning = false
		drones = [ProjectDrone]()
	}
	
	static func getCurrentProject() throws -> Project{
		if singleton == nil {throw ProjectError.noProjectInitialized}
		return singleton
	}
	
	static func setCurrentProject(id: String) -> Project {
		singleton = Project(id: id)
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Generic subroutines
	////////////////////////////////////////////////////////////
	
	static func addExternalProjectRequestClient(_ client: ProjectRequestClient) {
		externalProjectRequestClients.append(client)
	}
	
	func abort(client:ProjectRequestClient, requestID:String="") throws {
		
		try ensureProjectCanAbort()
		
		let request = ProjectRequest(
			pType: ProjectRequest.RequestType.abort.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pProject: self
		)
		
		ProjectRequestManager.getInstance().addRequest(request)
	}
	
	func addDrone(_ drone: Drone, employed:Bool=false) {
		do {
			let duplicateDrone = try getDroneByName(drone.state.name)
			throw ProjectError.duplicateDrone(droneName: duplicateDrone.drone.state.name)
		}
		catch {}
		
		let newDrone = ProjectDrone(pDrone: drone)
		newDrone.setEmployed(employed)
		
		drones.append(newDrone)
	}
	
	func getCompletionPercentage() -> Int {
		let employedDrones = getEmployedDrones()
		
		let droneCount = employedDrones.count
		if (droneCount == 0) {return 0}
		let supposedSum = droneCount * 100
		var sum = 0
		for drone in employedDrones { sum += drone.drone.getCompletionPercentage() }
		let output = Int((Float(sum) / Float(supposedSum)) * 100)
		return output
	}
	
	func getDroneByIndex(_ index: Int) throws -> ProjectDrone {
		if index < 0 || index > drones.count {throw ProjectError.invalidDroneIndex}
		return drones[index]
	}
	
	func getDroneByName(_ name: String) throws -> ProjectDrone {
		for projectDrone in drones {
			if projectDrone.drone.state.name == name {return projectDrone}
		}
		throw ProjectError.projectDroneNotFound(droneName: name)
	}
	
	func getDroneCount() -> Int { return drones.count }
	
	func getDrones() -> [ProjectDrone] {return drones}
	
	func getDroneListFromServer(client:ProjectRequestClient, requestID:String="") {
		let request = ProjectRequest(
			pType: ProjectRequest.RequestType.getDroneList.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pProject: self
		)
		
		ProjectRequestManager.getInstance().addRequest(request)
	}
	
	func getEmployedDroneCount() -> Int { return getEmployedDrones().count }
	
	func getEmployedDrones() -> [ProjectDrone] {
		var output = [ProjectDrone]()
		for projectDrone in drones {
			if projectDrone.isEmployed() {output.append(projectDrone)}
		}
		return output
	}
	
	func getOccupiedDroneCount() -> Int {
		var output = 0
		for projectDrone in drones { if projectDrone.drone.state.isOccupied {output+=1} }
		return output
	}
	
	func getStatus() -> ProjectStatus {
		if isRunning {return ProjectStatus.running}
		if canStart() {return ProjectStatus.ready}
		return ProjectStatus.idle
	}
	
	func hasOccupiedDrone() -> Bool { return getOccupiedDroneCount() > 0 }
	
	func refresh(client:ProjectRequestClient, requestID:String="") {
		
		let request = ProjectRequest(
			pType: ProjectRequest.RequestType.refresh.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pProject: self
		)
		
		ProjectRequestManager.getInstance().addRequest(request)
	}
	
	func setupDrones(client:ProjectRequestClient, requestID:String="") {
		
		let request = ProjectRequest(
			pType: ProjectRequest.RequestType.setupDrones.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pProject: self
		)
		
		ProjectRequestManager.getInstance().addRequest(request)
	}
	
	func start(client:ProjectRequestClient, requestID:String="") throws {
		
		try ensureProjectCanStart()
		
		let request = ProjectRequest(
			pType: ProjectRequest.RequestType.start.rawValue,
			pClients: getClients(client),
			pRequestID: requestID,
			pProject: self
		)
		
		ProjectRequestManager.getInstance().addRequest(request)
	}
	
	private func getClients(_ adhocClient: ProjectRequestClient) -> [ProjectRequestClient] {
		var output = [ProjectRequestClient]()
		output.append(self)
		output.append(adhocClient)
		for prc in Project.externalProjectRequestClients {output.append(prc)}
		return output
	}
	
	////////////////////////////////////////////////////////////
	// Project Request Client
	////////////////////////////////////////////////////////////

	func abortComplete(success: Bool, error: String) {
		if !success {return}
		self.isRunning = false
		for drone in getEmployedDrones() {
			drone.setEmployed(false)
			drone.drone.state.isOccupied = false
		}
	}
	
	func canStart() -> Bool {
		do {
			try ensureProjectCanStart()
			return true
		}
		catch {return false}
	}
	
	func ensureProjectCanAbort() throws {
		if !isRunning {throw ProjectError.notRunning}
	}
	
	func ensureProjectCanStart() throws {
		
		if isRunning {throw ProjectError.alreadyRunning}
		
		let employedDrones = getEmployedDrones()
		if employedDrones.count <= 0 {throw ProjectError.noEmployedDrone}
		
		for employedDrone in employedDrones {
			if !employedDrone.isSetupComplete() {
				throw ProjectError.droneNotReady(droneName:employedDrone.drone.state.name)
			}
		}
	}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {
		drones = [ProjectDrone]()
		
		for droneName in list {
			let droneState = DroneState(pName: droneName)
			let drone = Drone(droneState)
			let projectDrone = ProjectDrone(pDrone: drone)
			drones.append(projectDrone)
		}
	}
	
	func refreshComplete(success: Bool, error: String) {
		isRunning = hasOccupiedDrone()
	}
	
	func setupDronesComplete(success: Bool, error: String) {
		for drone in getEmployedDrones() { drone.setSetupComplete(success, info: error) }
	}
	
	func startComplete(success: Bool, error: String) {
		if !success {return}
		self.isRunning = true
		for drone in getEmployedDrones() { drone.drone.state.startedMission = true }
	}
	
}
