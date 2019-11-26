//
//  Drone.swift
//  Bastion
//
//  Created by Dr. Kerem Koseoglu on 9.05.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import DJISDK
import amongst
import EasyTelegram
import UIKit

class Drone {
	
	private var dji: DJIBaseProduct
	
	init(_ product: DJIBaseProduct) {
		dji = product
	}
	
	func abortProject() throws {
		#warning("abort")
		// tamamla
		// amon handler'dan buraya gel
	}
	
	func getActiveProject() -> String {
		#warning("proje adı düzelt")
		return "dummy"
	}
	
	func getDroneState() throws -> DroneState {
		var output = DroneState(pName: Settings.getTelegramSettings().botName)
		
		#warning("state'e aşağıdakileri de dahil et")
		/*output.baseCoordinate
		output.batteryPercentage
		output.completeMissionSteps
		output.coordinate
		output.finishedMission
		output.height
		output.isOccupied
		output.lastInfo
		output.mission
		output.startedMission
		output.totalMissionSteps*/
		
		return output
	}
	
	func getPhoto() throws -> UIImage {
		#warning("photo")
		// tamamla
		// aşağıdaki return değişecek
		// amon handler'dan buraya gel
		return UIImage(ciImage: CIImage(color: CIColor.green))
	}
	
	func setupForProject(project: String) throws {
		#warning("setup")
		// özgür'ün komut dosyasını indirip initialize etmelisin
		// tamamla
		// amon handler'dan buraya gel
	}
	
	func startProject() throws {
		#warning("start")
		// özgür'ün komut dosyasını işlemeye başlamalısın
		// tamamla
		// amon handler'dan buraya gel
	}
	
}
