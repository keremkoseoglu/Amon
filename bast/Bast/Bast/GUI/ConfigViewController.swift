//
//  ConfigViewController.swift
//  Bast
//
//  Created by Dr. Kerem Koseoglu on 7.05.2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import EasyTelegram
import EasyGUI
import Bastion

class ConfigViewController: UIViewController, Caller {

	@IBOutlet weak var txtTimeout: UITextField!
	@IBOutlet weak var txtPollFrequency: UITextField!
	@IBOutlet weak var txtTaskFrequency: UITextField!
	@IBOutlet weak var txtBotToken: UITextField!
	@IBOutlet weak var txtBotName: UITextField!
	@IBOutlet weak var txtRoomID: UITextField!
	
	private var vSpinner: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let ts = Settings.getTelegramSettings()
		txtRoomID.text = ts.roomID
		txtBotName.text = ts.botName
		txtBotToken.text = ts.botToken
		txtTaskFrequency.text = String(ts.taskManagerFrequency)
		txtPollFrequency.text = String(ts.pollFrequency)
		txtTimeout.text = String(ts.telegramTimeout)

        // Do any additional setup after loading the view.
    }
	
	////////////////////////////////////////////////////////////
	// User interaction
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
	
	func testCompleted(_ result: CommunicatorResult) {
		Gui.hideSpinner(vSpinner)
		
		var toastMsg = ""
		if result.success { toastMsg = "Success" } else { toastMsg = "Error: " + result.error }
		
		Gui.showToast(controller: self, message: toastMsg)
	}
	
	func newAmonCommands(result: CommunicatorResult, commands: [AmonRequest]) {
		assertionFailure("Unexpected callback")
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
