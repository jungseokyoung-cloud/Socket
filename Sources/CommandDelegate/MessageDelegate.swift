//
//  CommandDelegate.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum HandlerResultMode {
	case messageReturn(_ data: Data?)
	case modeChanged(_ mode: ConnectionMode)
}

protocol MessageDelegate: AnyObject {
	func echoModeHandler(message: String?) -> HandlerResultMode
}

// MARK: Echo Mode Message Handler
class MessageHandler: MessageDelegate {
	func echoModeHandler(message: String?) -> HandlerResultMode {
		let data = "echo: \(message ?? "")".data(using: .utf8)
		
		return .messageReturn(data)
	}
}
