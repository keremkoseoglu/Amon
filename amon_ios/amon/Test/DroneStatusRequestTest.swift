//
//  DroneStatusRequestTest.swift
//  amonTests
//
//  Created by Dr. Kerem Koseoglu on 13.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import amongst

class DroneStatusRequestTest: DroneRequestClient {
	
	var drone: Drone
	
	init() {
		let droneState = DroneState(pName: "kkbot02bot")
		drone = Drone(droneState)
	}
	

	func testDroneStatus() {
		
		// https://api.telegram.org/bot808248142:AAEhftGMYS33gjdfB5OcaEn4P0qk745Qz_0/sendMessage?chat_id=-1001171080087&text=/my_status drone:kkbot03bot project:PROJ1 started:TRUE active:TRUE finished:FALSE pos_lat:41.098039 pos_lon:29.093191 height:50 base_lat:41.101639 base_lon:29.089321 mission_steps:12 complete_steps:4 battery:62 info:NONE waypoints:[41.096497-29.099945;41.092390-29.097627;41.091218-29.096715] complete_waypoint:2

		
		drone.refreshState(client: self)
		print("State requested for " + drone.state.name)
	}
	
	//////////
	// Drone Request Client
	//////////
	
	func refreshStateComplete(state: DroneState, success: Bool, error: String) {
		if success {
			print("Success")
			drone.state = state
		}
		else {
			print("Error: " + error)
		}
	}
	
	func shootPhotoComplete(droneID: String, image: UIImage, success: Bool, error: String) {}
	
}
