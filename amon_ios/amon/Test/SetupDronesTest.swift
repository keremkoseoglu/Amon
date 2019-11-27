//
//  SetupDronesTest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

/*
Sample success URL: https://api.telegram.org/bot808248142:AAEhftGMYS33gjdfB5OcaEn4P0qk745Qz_0/sendMessage?chat_id=-1001171080087&text=/my_project_setup%20drone:kkbot03bot%20project:dummy%20success:TRUE
Sample fail URL: https://api.telegram.org/bot808248142:AAEhftGMYS33gjdfB5OcaEn4P0qk745Qz_0/sendMessage?chat_id=-1001171080087&text=/my_project_setup%20drone:kkbot03bot%20project:dummy%20success:FALSE%20info:BATTERY_ERROR
*/

import Foundation
import amongst

class SetupDronesTest: ProjectRequestClient {
	
	var project: Project!
	
	func setupDronesTest() {
		project = Project.setCurrentProject(id: "dummy")
		project.getDroneListFromServer(client: self)
		print("Asked for drone list")
	}
	
	//////////
	// Project Request Client
	//////////
	
	func abortComplete(success: Bool, error: String) {}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {
		print("Got drone list from server, adding to project")
		for droneName in list {
			print("Adding drone: " + droneName)
			project.addDrone(Drone(DroneState(pName: droneName)), employed:true)
		}
		print("Setting up drones")
		project.setupDrones(client: self)
	}
	
	func refreshComplete(success: Bool, error: String) {}
	
	func setupDronesComplete(success: Bool, error: String) {
		if success {
			print("Success")
		}
		else {
			print("Error: " + error)
		}
		
		for projectDrone in project.getDrones() {
			var empText = ""
			if projectDrone.isEmployed() {empText="employed"} else {empText = "not employed"}
			print("Drone " + projectDrone.drone.state.name + " is " + empText + " (info: " + projectDrone.getSetupInfo() + ")")
		}
	}
	
	func startComplete(success: Bool, error: String) {}
	
}
