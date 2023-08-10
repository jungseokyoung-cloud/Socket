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
	case modeDidFinishWithError(_ error: Data?)
	case clientDisconnet
}

@available(macOS 10.14, *)
protocol MessageDelegate: AnyObject {
	var clientID: Int { get }
	
	func echoModeHandler(message: String) -> HandlerResultMode
	func commandModeHandler(message: String) -> HandlerResultMode
	func personalChattingModeHandler(
		message: String,
		_ id: Int
	) -> HandlerResultMode
}

@available(macOS 10.14, *)
// MARK: Echo Mode Message Handler
class MessageHandler: MessageDelegate {
	let clientID: Int
	
	init(clientID: Int) {
		self.clientID = clientID
	}
	
	func echoModeHandler(message: String) -> HandlerResultMode {
		if message.removeCRLF == "checkout" {
			return .modeChanged(.command)
		} else {
			let data = "echo: \(message)".data(using: .utf8)
			return .messageReturn(data)
		}
	}
}

@available(macOS 10.14, *)
// MARK: Command Mode Message Handler
extension MessageHandler {
	func commandModeHandler(message: String) -> HandlerResultMode {
		/// split command and Argument
		let command = message.removeCRLF.split(separator: " ").map { String($0) }
		
		if command.count == 1 {
			return processSingleCommand(command[0])
		} else if command.count == 2 {
			if command[0] == "chat" {
				return enterPersonalChatting(command[1])
			} else if command[0] == "group" {
				return enterGroupChatting(command[1])
			} else {
				let errorMessage = CommandError.unkownCommand.description
				return .errorReturn(errorMessage.data(using: .utf8))
			}
		} else {
			let errorMessage = CommandError.unkownCommand.description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
	}
	
	/// Single Command
	func processSingleCommand(_ command: String) -> HandlerResultMode {
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
			let optionMessage = ServerMessage.option.description
			return .messageReturn(optionMessage.data(using: .utf8))
			// exit Command: end Connection
		} else if command == "exit" {
			return .clientDisconnet
		} else {
			let errorMessage = CommandError.unkownCommand.description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
	}
	
	func enterPersonalChatting(_ argument: String) -> HandlerResultMode {
		guard let id = Int(argument) else {
			let errorMessage = CommandError.unkownCommand.description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
		
		guard
			clientID != id,
			Server.connectionsByID[id] != nil
		else {
			let errorMessage = CommandError.invalidClientID(id).description
			return .errorReturn(errorMessage.data(using: .utf8))
		}
		return .modeChanged(.personalChatting(id))
	}
	
	func enterGroupChatting(_ argument: String) -> HandlerResultMode {
		return .messageReturn("group".appendCRLF.data(using: .utf8))
	}
}

@available(macOS 10.14, *)
// MARK: Personal Chatting Message Handler
extension MessageHandler {
	func personalChattingModeHandler(
		message: String,
		_ id: Int
	) -> HandlerResultMode {
		guard let connection = Server.connectionsByID[id] else {
			let errorMessage = CommandError.invalidClientID(id).description
			return .modeDidFinishWithError(errorMessage.data(using: .utf8))
		}
		
		if message.removeCRLF == "checkout" {
			return .modeChanged(.command)
		} else {
			let fromMessage = "from \(self.clientID): \(message)"
			let toMessage = "to \(id): \(message)"

			connection.send(data: fromMessage.data(using: .utf8))
			return .messageReturn(toMessage.data(using: .utf8))
		}
	}
}
