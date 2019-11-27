//
//  SettingsViewController.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 11.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit
import EasyTelegram
import EasyGUI
import amongst

class SettingsViewController: UIViewController, Caller, ProjectRequestClient {
	
	@IBOutlet weak var txtRoomID: UITextField!
	@IBOutlet weak var txtBotName: UITextField!
	@IBOutlet weak var txtBotToken: UITextField!
	@IBOutlet weak var txtTaskFrequency: UITextField!
	@IBOutlet weak var txtPollFrequency: UITextField!
	@IBOutlet weak var txtTimeout: UITextField!
	
	
	@IBOutlet weak var btnTest: UIButton!
	@IBOutlet weak var btnSave: UIButton!
	
	
	private var vSpinner: UIView!
	private var subscribedToProjectEvents: Bool = false
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let ts = Settings.getTelegramSettings()
		txtRoomID.text = ts.roomID
		txtBotName.text = ts.botName
		txtBotToken.text = ts.botToken
		txtTaskFrequency.text = String(ts.taskManagerFrequency)
		txtPollFrequency.text = String(ts.pollFrequency)
		txtTimeout.text = String(ts.telegramTimeout)
		
		if !subscribedToProjectEvents {
			Project.addExternalProjectRequestClient(self)
			subscribedToProjectEvents = true
		}
    }
	
	////////////////////////////////////////////////////////////
	// GUI Events
	////////////////////////////////////////////////////////////
	
	
	@IBAction func testClick(_ sender: Any) {
		vSpinner = Gui.showSpinner(onView: self.view)
		CommunicatorFactory.getCommunicator().test(self)
	}
	
	@IBAction func saveClick(_ sender: Any) {		
		var ts = TelegramSettings()
		ts.botName = txtBotName.text ?? ""
		ts.botToken = txtBotToken.text ?? ""
		ts.roomID = txtRoomID.text ?? ""
		ts.pollFrequency = Int(txtPollFrequency.text ?? "0") ?? 0
		ts.taskManagerFrequency = Int(txtTaskFrequency.text ?? "0") ?? 0
		ts.telegramTimeout = Int(txtTimeout.text ?? "0") ?? 0
		Settings.setTelegramSettings(ts)
		
		UIImpactFeedbackGenerator().impactOccurred()
	}
	
	////////////////////////////////////////////////////////////
	// Caller stuff
	////////////////////////////////////////////////////////////
	
	func abortProjectCompleted(result: CommunicatorResult) {}
	func announcementCompleted(result: CommunicatorResult) {}
	func droneListFetched(result: CommunicatorResult, droneList: [String]) {}
	func dronePhotoCompleted(result: CommunicatorResult, photo: UIImage, droneID: String) {}
	func droneStateCompleted(result: CommunicatorResult, droneState: DroneState) {}
	func initCompleted(_ result: CommunicatorResult) {}
	func refreshProjectCompleted(result: CommunicatorResult) {}
	func setupProjectCompleted(result: CommunicatorResult) {}
	func startProjectCompleted(result: CommunicatorResult) {}
	
	func testCompleted(_ result: CommunicatorResult) {
		Gui.hideSpinner(vSpinner)
		
		var toastMsg = ""
		if result.success { toastMsg = "Success" } else { toastMsg = "Error: " + result.error }
		
		Gui.showToast(controller: self, message: toastMsg)
	}
	
	////////////////////////////////////////////////////////////
	// Project Request client
	////////////////////////////////////////////////////////////
	
	func abortComplete(success: Bool, error: String) { setViewEnabled(true) }
	func getDroneListComplete(list: [String], success: Bool, error: String) {}
	
	func refreshComplete(success: Bool, error: String) {
		
		var enable = true
		
		do {
			let p = try Project.getCurrentProject()
			enable = !p.isRunning
		}
		catch {}
		setViewEnabled(enable)
		
	}
	
	func setupDronesComplete(success: Bool, error: String) { }
	func startComplete(success: Bool, error: String) { setViewEnabled(false) }

	////////////////////////////////////////////////////////////
	// Internal stuff
	////////////////////////////////////////////////////////////
	
	private func setViewEnabled(_ enabled: Bool) {
		txtRoomID.isEnabled = enabled
		txtBotName.isEnabled = enabled
		txtBotToken.isEnabled = enabled
		txtTimeout.isEnabled = enabled
		txtPollFrequency.isEnabled = enabled
		txtTaskFrequency.isEnabled = enabled
		btnTest.isEnabled = enabled
		btnSave.isEnabled = enabled
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
