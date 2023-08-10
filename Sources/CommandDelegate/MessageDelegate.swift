//
//  CommandDelegate.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum HandlerResultMode {
	case messageReturn(_ data: Data?)
	case errorReturn(_ error: Data?)
	case modeChanged(_ mode: ConnectionMode)
	case clientDisconnet
}

protocol MessageDelegate: AnyObject {
	func echoModeHandler(message: String?) -> HandlerResultMode
	func commandModeHandler(message: String?) -> HandlerResultMode
}

// MARK: Echo Mode Message Handler
class MessageHandler: MessageDelegate {
	func echoModeHandler(message: String?) -> HandlerResultMode {
		let data = "echo: \(message ?? "")".data(using: .utf8)
		
		return .messageReturn(data)
	}
}

// MARK: Command Mode Message Handler
extension MessageHandler {
	func commandModeHandler(message: String?) -> HandlerResultMode {
		guard let message = message else { return .errorReturn(nil) }
		
		/// split command and Argument
		let command = message.removeCRLF.split(separator: " ").map { String($0) }

		if command.count == 1 {
			return processSingleCommand(command[0])
		} else if command.count == 2 {
			return processCommandWithArgument(command[0], argument: command[1])
		} else {
			let errorMessage = CommandError.unkownCommand.description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
	}
	
	func processSingleCommand(_ command: String) -> HandlerResultMode {
		if #available(macOS 10.14, *) {
			if command == "clientlist" {
				let ids = Server.connectionsByID.map{ "\($0.key)" }
				let idMessage = ids.joined(separator: ", ").appendCRLF
				return .messageReturn(idMessage.data(using: .utf8))
				/// grouplist Command: return Group list message
			} else if command == "grouplist" {
				let message = "group list".appendCRLF
				return .messageReturn(message.data(using: .utf8))
				/// echo Command: change to echo Mode
			} else if command == "echo" {
				return .modeChanged(.echo)
				/// option Command: return Option message
			} else if command == "option" {
				let optionMessage = ServerMessage.optionMessage.description
				return .messageReturn(optionMessage.data(using: .utf8))
			} else if command == "exit" {
				return .clientDisconnet
			} else {
				let errorMessage = CommandError.unkownCommand.description
				return .errorReturn(errorMessage.data(using: .utf8))
			}
		} else {
			return .errorReturn(nil)
		}
	}
	
	func processCommandWithArgument(_ command: String, argument: String) -> HandlerResultMode {
		guard let id = Int(argument) else {
			let errorMessage = CommandError.unkownCommand.description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
		
		let message = "two Line Command".appendCRLF
		return .messageReturn(message.data(using: .utf8))
	}
}
