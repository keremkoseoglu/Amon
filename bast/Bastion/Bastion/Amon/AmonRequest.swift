//
//  AmonRequest.swift
//  Bastion
//
//  Created by Dr. Kerem Koseoglu on 8.05.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

public struct AmonRequest {
	
	public enum RequestType {
		case projectAbort;
		case projectSetup;
		case projectStart;
		case reportStatus;
		case shootPhoto;
	}
	
	public var requestType: RequestType
	public var project: String
	
	public init(pRequestType: RequestType, pProject: String="") {
		requestType = pRequestType
		project = pProject
	}
	
}
