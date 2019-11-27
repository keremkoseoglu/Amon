//
//  MutCommunicator.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 17.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import EasyHTTP
import amongst

class MutCommunicator : HttpClient, Caller {
	
	private enum MutRequestType {
		case isDisabled
		case killApp
		case notifyDeveloper
		case undefined
	}

	
	private static var singleton: MutCommunicator!
	private var currentRequest: MutRequestType
	private var errandsExecuted: Bool
	
	////////////////////////////////////////////////////////////
	// Factory
	////////////////////////////////////////////////////////////
	
	private init() {
		currentRequest = MutRequestType.undefined
		errandsExecuted = false
	}
	
	static func getInstance() -> MutCommunicator {
		if singleton == nil { singleton = MutCommunicator() }
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Internal Stuff
	////////////////////////////////////////////////////////////
	
	private func disableApp() {
		currentRequest = MutRequestType.killApp
		let message = "The app is centrally disabled by the developer. It will be closed."
		print(message)
		CommunicatorFactory.getCommunicator().announce(message: message, caller: self)
	}
	
	func runErrands() {
		if errandsExecuted {return}
		errandsExecuted = true
		notifyDeveloper()
	}
	
	private func ensureAmonNotDisabled() {
		currentRequest = MutRequestType.isDisabled
		Http().get(
			client: self,
			parameters: [:],
			url: "https://amon-mut.herokuapp.com/api/getAmonConfig"
		)
	}
	
	private func handleAmonConfigReply(json: [String : Any]) {
		currentRequest = MutRequestType.undefined
		let is_disabled = json["is_disabled"] as? Bool ?? false
		if is_disabled {disableApp()}
	}
	
	private func notifyDeveloper() {
		currentRequest = MutRequestType.notifyDeveloper
		Http().get(
			client: self,
			parameters: ["device_id": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"],
			url: "https://amon-mut.herokuapp.com/api/appRunning"
		)
	}
	
	////////////////////////////////////////////////////////////
	// HTTP
	////////////////////////////////////////////////////////////

	func handle_http_error(error: Error) {
		print("Mut HTTP Error: " + error.localizedDescription)
	}
	
	func handle_http_response(json: [String : Any]) {
		switch currentRequest {
		case MutRequestType.notifyDeveloper: ensureAmonNotDisabled()
		case MutRequestType.isDisabled: handleAmonConfigReply(json: json)
		default: return
		}
	}
	
	////////////////////////////////////////////////////////////
	// Caller
	////////////////////////////////////////////////////////////
	
	func abortProjectCompleted(result: CommunicatorResult) {}
	
	func announcementCompleted(result: CommunicatorResult) {
		if currentRequest == MutRequestType.killApp {
			currentRequest = MutRequestType.undefined
			DispatchQueue.main.async { exit(EXIT_SUCCESS) }
		}
	}
	
	func droneListFetched(result: CommunicatorResult, droneList: [String]) {}
	
	func dronePhotoCompleted(result: CommunicatorResult, photo: UIImage, droneID: String) {}
	
	func droneStateCompleted(result: CommunicatorResult, droneState: DroneState) {}
	
	func initCompleted(_ result: CommunicatorResult) {}
	
	func refreshProjectCompleted(result: CommunicatorResult) {}
	
	func setupProjectCompleted(result: CommunicatorResult) {}
	
	func startProjectCompleted(result: CommunicatorResult) {}
	
	func testCompleted(_ result: CommunicatorResult) {}
	
}


