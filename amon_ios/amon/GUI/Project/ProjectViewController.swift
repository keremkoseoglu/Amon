//
//  FirstViewController.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 10.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit
import EasyGUI
import amongst

class ProjectViewController: UIViewController, ProjectRequestClient, DroneRequestClient {

	@IBOutlet weak var btnDrones: UIButton!
	@IBOutlet weak var btnInitialize: UIButton!
	@IBOutlet weak var btnStart: UIButton!
	@IBOutlet weak var btnAbort: UIButton!
	@IBOutlet weak var btnRefresh: UIButton!
	
	@IBOutlet weak var lblStatus: UILabel!
	@IBOutlet weak var lblCompletion: UILabel!
	@IBOutlet weak var lblDroneCount: UILabel!
	@IBOutlet weak var lblActiveDrones: UILabel!
	
	@IBOutlet weak var txtProject: UITextField!
	
	
	private var spinner: UIView!
	private var subscribedToDroneUpdates: Bool = false
	
	private enum ProjectViewError: Error {
		case projectIDNotEntered
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if !subscribedToDroneUpdates { Drone.addExternalDroneRequestClient(self) }
	}
	
	////////////////////////////////////////////////////////////
	// UI clicks
	////////////////////////////////////////////////////////////
	
	
	@IBAction func btnDronesClick(_ sender: Any) {
		var projectID = ""
		do { projectID = try getProjectIDFromView() } catch {return}
		showSpinner()
		Project.setCurrentProject(id: projectID).getDroneListFromServer(client: self)
	}
	
	@IBAction func btnInitializeClick(_ sender: Any) {
		
		do {
			let project = try Project.getCurrentProject()
			showSpinner()
			project.setupDrones(client: self)
		}
		catch {
			showToast(error.localizedDescription)
			return
		}
	}
	
	@IBAction func btnStartClick(_ sender: Any) {
		
		do {
			showSpinner()
			try Project.getCurrentProject().start(client: self)
		} catch {
			hideSpinner()
			showToast(error.localizedDescription)
		}
	}
	
	@IBAction func btnAbortClick(_ sender: Any) {
		do {
			showSpinner()
			try Project.getCurrentProject().abort(client: self)
		} catch {
			hideSpinner()
			showToast(error.localizedDescription)
		}
	}
	
	@IBAction func btnRefreshClick(_ sender: Any) {
		do {
			showSpinner()
			let project = try Project.getCurrentProject()
			project.refresh(client: self)
		}
		catch {
			hideSpinner()
			showToast(error.localizedDescription)
			return
		}
	}
	
	////////////////////////////////////////////////////////////
	// Generic subroutines
	////////////////////////////////////////////////////////////
	
	private func getProjectIDFromView() throws -> String {
		let projectID = txtProject.text ?? ""
		if projectID == "" {
			showToast("Please enter a project ID")
			throw ProjectViewError.projectIDNotEntered
		}
		return projectID
	}
	
	private func hideSpinner() { Gui.hideSpinner(spinner) }
	
	private func repaintStatus() {
			
		var project: Project
		
		do {
			project = try Project.getCurrentProject()
		}
		catch {
			self.showToast(error.localizedDescription)
			return
		}
		
		lblStatus.text = project.getStatus().rawValue
		lblCompletion.text = String(project.getCompletionPercentage()) + "%"
		lblDroneCount.text = String(project.getDroneCount())
		lblActiveDrones.text = String(project.getOccupiedDroneCount())
		
		setProjectControlsEnabled(!project.isRunning)
	}
	
	private func setProjectControlsEnabled(_ enabled: Bool) {
		btnDrones.isEnabled = enabled
		btnInitialize.isEnabled = enabled
		txtProject.isEnabled = enabled
		btnStart.isEnabled = enabled
		btnAbort.isEnabled = !enabled
		btnRefresh.isEnabled = !enabled
	}
	
	private func showSpinner() { spinner = Gui.showSpinner(onView: self.view) }
	private func showToast(_ message: String) { Gui.showToast(controller: self, message: message) }

	////////////////////////////////////////////////////////////
	// Project Request
	////////////////////////////////////////////////////////////
	
	func abortComplete(success: Bool, error: String) {
		DispatchQueue.main.async {
			self.hideSpinner()
			
			if !success {
				self.showToast(error)
				return
			}
			
			self.repaintStatus()
		}
	}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {
		DispatchQueue.main.async {
			self.hideSpinner()
			
			if !success {
				self.showToast(error)
				return
			}
			
			self.repaintStatus()
			self.btnInitialize.isEnabled = true
		}
	}
	
	func refreshComplete(success: Bool, error: String) {
		
		DispatchQueue.main.async {
			self.hideSpinner()
			if !success { self.showToast(error) }
			self.repaintStatus()
		}
	}
	
	func setupDronesComplete(success: Bool, error: String) {
		DispatchQueue.main.async {
			self.hideSpinner()
			
			if success {
				self.btnStart.isEnabled = true
			}
			else {
				self.showToast(error)
			}
			
			self.repaintStatus()
			
		}
	}
	
	func startComplete(success: Bool, error: String) {
		
		DispatchQueue.main.async {
			self.hideSpinner()
			if success {
				self.showToast("Project started")
			}
			else {
				self.showToast(error)
			}
			
			self.repaintStatus()
		}
	}
	
	////////////////////////////////////////////////////////////
	// Drone Request
	////////////////////////////////////////////////////////////
	
	func refreshStateComplete(state: DroneState, success: Bool, error: String) { DispatchQueue.main.async { self.repaintStatus() } }
	func shootPhotoComplete(droneID: String, image: UIImage, success: Bool, error: String) {}
	
}


