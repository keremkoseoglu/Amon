//
//  Drone.swift
//  amongst
//
//  Created by Dr. Kerem Koseoglu on 9.05.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import MapKit

public struct DroneState {
	
	public var name: String
	public var startedMission: Bool
	public var isOccupied: Bool
	public var finishedMission: Bool
	public var coordinate: CLLocationCoordinate2D
	public var height: Int
	public var baseCoordinate: CLLocationCoordinate2D
	public var totalMissionSteps: Int
	public var completeMissionSteps: Int
	public var batteryPercentage: Int
	public var lastInfo: String
	public var mission: DroneMission
	
	public init(pName: String) {
		name = pName
		startedMission = false
		isOccupied = false
		finishedMission = false
		coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		height = 0
		baseCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		totalMissionSteps = 0
		completeMissionSteps = 0
		batteryPercentage = 0
		lastInfo = ""
		mission = DroneMission()
	}
	
}
