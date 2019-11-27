//
//  DroneTableViewCell.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 18.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import UIKit

class DroneTableViewCell: UITableViewCell {

	@IBOutlet weak var lblDroneName: UILabel!
	@IBOutlet weak var lblDroneSetup: UILabel!

	@IBOutlet weak var switchDroneEmployed: UISwitch!
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	////////////////////////////////////////////////////////////
	// User input handling
	////////////////////////////////////////////////////////////

	@IBAction func switchEmployedChange(_ sender: Any) {
		
		do {
			let project = try Project.getCurrentProject()
			let projectDrone = try project.getDroneByName(lblDroneName.text!)
			projectDrone.setEmployed(switchDroneEmployed.isOn)
		}
		catch {return}

	}
}
