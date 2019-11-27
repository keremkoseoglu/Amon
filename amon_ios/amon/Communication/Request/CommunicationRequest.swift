//
//  CommunicationRequest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 13.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation

protocol CommunicationRequestClient {}

protocol CommunicationRequest {
	var requestID: String {get}
	var requestType: String {get}
	var clients: [CommunicationRequestClient] {get}
}

class CommunicationRequestManager {

	internal var requests: [CommunicationRequest]
	internal var processing: Bool
	internal var currentClients: [CommunicationRequestClient]!
	
	////////////////////////////////////////////////////////////
	// Constructors
	////////////////////////////////////////////////////////////
	
	internal init() {
		requests = [CommunicationRequest]()
		processing = false
	}
	
	////////////////////////////////////////////////////////////
	// Queue processing
	////////////////////////////////////////////////////////////
	
	public func addRequest(_ request: CommunicationRequest) {
		requests.append(request)
		processNextRequest()
	}
	
	private func processNextRequest() {
		if processing {return}
		if requests.count <= 0 {return}
		
		processing = true
		let nextRequest = requests[0]
		currentClients = nextRequest.clients
		
		processRequest(nextRequest)
	}
	
	internal func processRequest(_ request: CommunicationRequest) {
		assertionFailure("CommunicationRequestManager.processRequest must be overriden")
	}
	
	internal func skipToNextRequest() {
		if requests.count <= 0 {return}
		requests.remove(at: 0)
		processing = false
		processNextRequest()
	}
	
}


