//
//  DroneListRequestTest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

class DroneListRequestTest: ProjectRequestClient {

	func testDroneList() {
		Project.setCurrentProject(id: "dummy").getDroneListFromServer(client: self)
	}
	
	//////////
	// Project Request Client
	//////////
	
	func abortComplete(success: Bool, error: String) {}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {
		if success {
			print("Success")
			for droneName in list {
				print("Detected drone: " + droneName)
			}
		}
		else {
			print("Error: " + error)
		}
	}
	
	func refreshComplete(success: Bool, error: String) {}
	
	func setupDronesComplete(success: Bool, error: String) {	}
	
	func startComplete(success: Bool, error: String) {}
}
