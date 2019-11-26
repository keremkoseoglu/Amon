//
//  DroneMission.swift
//  amongst
//
//  Created by Dr. Kerem Koseoglu on 9.05.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import MapKit

public class DroneMission {
	
	public var waypoints: [CLLocationCoordinate2D]
	public var lastCompleteWaypointIndex: Int
	
	public init() {
		waypoints = [CLLocationCoordinate2D]()
		lastCompleteWaypointIndex = -1
	}
	
}
