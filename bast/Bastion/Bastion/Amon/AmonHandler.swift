//
//  AmonHandler.swift
//  Bast
//
//  Created by Dr. Kerem Koseoglu on 7.05.2019.
//  Copyright © 2019 DJI. All rights reserved.
//

/*
To support a new Amon command:
- Add a new RequestType below
- Edit TelegramBotEar.readCommands to support the new command
- Edit Drone to support the new command there if needed
- Support the new command in AmonRequest.newAmonCommands
*/

import Foundation
import EasyTelegram
import amongst
import DJISDK

public class AmonHandler: Caller {
	
	private static var singleton: AmonHandler!
	private var botEarTimer: Timer!
	private var drone: Drone
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	private init() {		
		#warning("MUT")
		// final hariç diğer işler bitsin
		// mut için ortak sınıf yap amon'da (yoksa)
		// aşağısı MUT ile çalışsın
		// MutCommunicator.getInstance().runErrands()
		
		#warning("final")
		// tüm işler bitsin
		// long poll çalışması sırasında hata oluyorsa kullanıcıyı haberdar etmeliyiz
	}
	
	private func setDrone(_ pDrone: DJIBaseProduct) {
		drone = Drone(pDrone)
	}
	
	public static func getInstance(pDrone: DJIBaseProduct) -> AmonHandler {
		if singleton == nil {singleton = AmonHandler()}
		singleton.setDrone(pDrone)
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Requests from Amon
	////////////////////////////////////////////////////////////
	
	public func startListening() {
		TelegramBotEar.getInstance().passCommands()
		
		if botEarTimer == nil {
			var interval: Double = Double(TelegramSettings().pollFrequency)
			if interval <= 0 {interval = TelegramCommunicator.DEFAULT_FREQUENCY}
			
			botEarTimer = Timer.scheduledTimer(
				withTimeInterval: interval,
				repeats: true,
				block: { longPollSubmitTimer in self.readNewAmonCommands() }
			)
		}
	}
	
	public func readNewAmonCommands() {
		CommunicatorFactory.getCommunicator().getNewAmonCommands(caller: self)
	}
	
	public func newAmonCommands(result: CommunicatorResult, commands: [AmonRequest]) {
		
		#warning("aşağıdakileri abort project gibi ayrı yordamlar yapıp çağır")
		
		for command in commands {
			switch command.requestType {
			case AmonRequest.RequestType.projectAbort:
				abortProject()
			case AmonRequest.RequestType.projectSetup:
				#warning("project setup")
			case AmonRequest.RequestType.projectStart:
				#warning("project start")
			case AmonRequest.RequestType.reportStatus:
				reportStatus()
			case AmonRequest.RequestType.shootPhoto:
				#warning("shoot photo")
			}
		}
		
		#warning("amon komutları")
		// yukarıda elde ettiğin amon komutlarını destekle, cevap verebiliyor ol
		// ana ekranda amon feedback gösterebiliyor olmalısın
		// AmonHandler'in en başındaki Comment'lere ek yap yeni eklerken ne yapmak gerekiyor diye
	}
	
	public func testCompleted(_ result: CommunicatorResult) {}
	
	////////////////////////////////////////////////////////////
	// Responses to Amon
	////////////////////////////////////////////////////////////
	
	private func abortProject() {
		#warning("burada kaldın")
		var message = "/my_project_abortion drone:" + Settings.getTelegramSettings().botName + " project:"
		
		do {
			try drone.abortProject()
		}
		catch {
			
		}
		
		CommunicatorFactory.getCommunicator().replyAmon(message: message)
	}
	
	private func reportStatus() {
		let status = drone.getDroneState()
		
		var waypoints = "["
		var firstWaypoint = true
		for wp in status.mission.waypoints {
			if firstWaypoint {firstWaypoint = false} else {waypoints += ";"}
			waypoints += String(wp.latitude) + "-" + String(wp.longitude)
		}
		waypoints += "]"
		
		var message = "/my_status"
		message += " drone:" + Settings.getTelegramSettings().botName
		message += " project:" + drone.getActiveProject()
		message += " started:" + String(status.startedMission ? "TRUE" : "FALSE")
		message += " active:" + String(status.isOccupied ? "TRUE" : "FALSE")
		message += " finished:" + String(status.finishedMission ? "TRUE": "FALSE")
		message += " pos_lat:" + String(status.coordinate.latitude)
		message += " pos_lon:" + String(status.coordinate.longitude)
		message += " height:" + String(status.height)
		message += " base_lat:" + String(status.baseCoordinate.latitude)
		message += " base_lon:" + String(status.baseCoordinate.longitude)
		message += " mission_steps:" + String(status.totalMissionSteps)
		message += " complete_steps:" + String(status.completeMissionSteps)
		message += " battery:" + String(status.batteryPercentage)
		message += " info:" + status.lastInfo
		message += " waypoints:" + waypoints
		message += " complete_waypoint:" + String(status.mission.lastCompleteWaypointIndex + 1)
		
		CommunicatorFactory.getCommunicator().replyAmon(message: message)
		
		#warning("bastion uygulaması ve test")
		// drone içerisindeki getDroneState düzgün bilgi döndürüyor olsun
		// akabinde, bastion gui iyi kötü hazır hale geliyor, bast'a uygula
		// statü üzerinden test et
		// korhan'a ilet
	}
	

	
	
}
