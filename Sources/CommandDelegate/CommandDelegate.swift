//
//  CommandDelegate.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum CommandMode {
	case messageReturn(_ data: Data?)
	case modeChanged(_ mode: ConnectionMode)
}

protocol CommandDelegate: AnyObject {
	func echoModeHandler(message: String?) -> CommandMode
}

// MARK: Echo Mode Message Handler
class CommandHandler: CommandDelegate {
	func echoModeHandler(message: String?) -> CommandMode {
		let data = "echo: \(message ?? "")".data(using: .utf8)
		
		return .messageReturn(data)
	}
}
