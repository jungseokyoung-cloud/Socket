//
//  ServerMessage.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

import Foundation

enum ServerMessage {
	case welcomeMessage(_ id: Int)
}

extension ServerMessage {
	var description: String {
		switch self {
		case .welcomeMessage(let id):
			return "You are connection: \(id)\n"
		}
	}
}
