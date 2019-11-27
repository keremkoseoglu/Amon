//
//  TelegramDroneStatus.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 12.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import MapKit
import EasyTelegram
import amongst

class TelegramDroneStatus : TelegramDroneTaskWorker {
	
	static var botReplyCommand = "/my_status"
	private var droneState: DroneState!

	////////////////////////////////////////////////////////////
	// Own stuff
	////////////////////////////////////////////////////////////
	
	func getDroneState() -> DroneState {return droneState}
	
	////////////////////////////////////////////////////////////
	// TelegramDroneTaskWorker
	////////////////////////////////////////////////////////////
	
	override internal func getBotQuestionCommand() -> String {
		droneState = DroneState(pName:droneID)
		return TelegramDroneStatus.getDroneQuestion(droneID)
	}
	
	override internal func getBotReplyCommand() -> String {
		return TelegramDroneStatus.botReplyCommand
	}
	
	override internal func handleBotReply(_ reply: TelegramBotReply) {
		droneState = TelegramDroneStatus.parseReply(reply)
		currentWorkClient?.workCompleted(result: result)
	}
	
	////////////////////////////////////////////////////////////
	// Internal stuff
	////////////////////////////////////////////////////////////
	
	private static func getCoordFromBotReply(reply: TelegramBotReply, latVar: String, longVar: String) -> CLLocationCoordinate2D {
		return getCoordFromStrings(
			latStr: reply.getValue(latVar),
			longStr: reply.getValue(longVar)
		)
	}
	
	private static func getCoordFromStrings(latStr: String, longStr: String) -> CLLocationCoordinate2D {
		
		var latDouble: Double = 0
		var longDouble: Double = 0
		
		if latStr != "" && longStr != "" {
			latDouble = Double(latStr) ?? 0
			longDouble = Double(longStr) ?? 0
		}
		
		return CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble)
	}
	
	private static func parseReplyForMission(_ reply: TelegramBotReply) -> DroneMission {
		let output = DroneMission()
		
		let waypoints = reply.getValue("waypoints")
		if waypoints != "" {
			let splitWaypoints = waypoints.split(separator: ";")
			for splitWaypoint in splitWaypoints {
				let swpText = String(splitWaypoint).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
				let coords = swpText.split(separator: "-")
				if coords.count == 2 {
					let lat = String(coords[0])
					let long = String(coords[1])
					let coord = getCoordFromStrings(latStr: lat, longStr: long)
					output.waypoints.append(coord)
				}
			}
		}
		
		output.lastCompleteWaypointIndex = Int(reply.getValue("complete_waypoint")) ?? 0 - 1
		
		return output
	}
	
	////////////////////////////////////////////////////////////
	// Shared stuff
	////////////////////////////////////////////////////////////

	static func getDroneQuestion(_ droneID: String) -> String {
		return "/get_status drone:" + droneID
	}
	
	static func parseReply(_ reply: TelegramBotReply) -> DroneState {
		var output = DroneState(pName: "")
		
		output.baseCoordinate = getCoordFromBotReply(reply: reply, latVar: "base_lat", longVar: "base_lon")
		output.batteryPercentage = Int(reply.getValue("battery")) ?? 0
		output.completeMissionSteps = Int(reply.getValue("complete_steps")) ?? 0
		output.coordinate = getCoordFromBotReply(reply: reply, latVar: "pos_lat", longVar: "pos_lon")
		output.finishedMission = reply.getValue("finished") == "TRUE"
		output.height = Int(reply.getValue("height")) ?? 0
		output.isOccupied = reply.getValue("active") == "TRUE"
		output.lastInfo = reply.getValue("info")
		output.name = reply.getValue("drone")
		output.startedMission = reply.getValue("started") == "TRUE"
		output.totalMissionSteps = Int(reply.getValue("mission_steps")) ?? 0
		output.mission = TelegramDroneStatus.parseReplyForMission(reply)
		
		return output
	}
	
}
