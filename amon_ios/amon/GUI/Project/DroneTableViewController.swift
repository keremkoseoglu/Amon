//
//  DroneTableViewController.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 18.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit
import amongst

class DroneTableViewController: UITableViewController, ProjectRequestClient, DroneRequestClient {
	
	////////////////////////////////////////////////////////////
	// UITableViewController stuff
	////////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()
		Project.addExternalProjectRequestClient(self)
		Drone.addExternalDroneRequestClient(self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		do {
			let project = try Project.getCurrentProject()
			return project.getDroneCount()
		}
		catch {return 0}

    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: "DroneCell",
			for: indexPath
			) as? DroneTableViewCell else { fatalError("Internal error") }
		
		do {
			let project = try Project.getCurrentProject()
			let projectDrone = try project.getDroneByIndex(indexPath.row)
			cell.lblDroneName.text = projectDrone.drone.state.name
			cell.switchDroneEmployed.isOn = projectDrone.isEmployed()
			cell.switchDroneEmployed.isEnabled = !project.isRunning
			
			if projectDrone.isSetupComplete() {
				cell.lblDroneSetup.text = AmonGui.Icon.green.rawValue
			}
			else {
				cell.lblDroneSetup.text = AmonGui.Icon.red.rawValue
			}
			
		} catch {}
		
		cell.accessoryType = .detailDisclosureButton

		return cell 
    }
	
	/*override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		
		do {
			selectedDrone = try Project.getCurrentProject().getDroneByIndex(indexPath.row)			
		} catch {}
	}*/
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

	////////////////////////////////////////////////////////////
	// View Controller
	///////////////////////////////////////////////////////////
	
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
		if segue.identifier == "showDroneDetails" {
			
			do {
				guard let vc = segue.destination as? DroneViewController else { fatalError("Cant assign vc") }
				
				let cell = sender as? DroneTableViewCell
				
				let selectedDrone = try Project.getCurrentProject().getDroneByName((cell?.lblDroneName.text)!)
				vc.projectDrone = selectedDrone
			}
			catch {
				fatalError(error.localizedDescription)
			}
			
			
		}
    }
	
	////////////////////////////////////////////////////////////
	// Project request client
	////////////////////////////////////////////////////////////
	
	func abortComplete(success: Bool, error: String) {
		refreshTableView()
	}
	
	func getDroneListComplete(list: [String], success: Bool, error: String) {
		refreshTableView()
	}
	
	func refreshComplete(success: Bool, error: String) {
		refreshTableView()
	}
	
	func setupDronesComplete(success: Bool, error: String) {
		refreshTableView()
	}
	
	func startComplete(success: Bool, error: String) {
		refreshTableView()
	}
	
	////////////////////////////////////////////////////////////
	// Drone request client
	////////////////////////////////////////////////////////////
	
	func refreshStateComplete(state: DroneState, success: Bool, error: String) {
		refreshTableView()
	}
	
	func shootPhotoComplete(droneID: String, image: UIImage, success: Bool, error: String) {}
	
	////////////////////////////////////////////////////////////
	// Generic subroutines
	////////////////////////////////////////////////////////////
	
	private func refreshTableView() {
		DispatchQueue.main.async { self.tableView.reloadData() }
	}
	
}
