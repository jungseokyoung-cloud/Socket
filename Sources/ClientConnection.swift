//
//  ClientConnection.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation
import Network

@available(macOS 10.14, *)
class ClientConnection {
	let MTU = 65536
	private static var nextID: Int = 1
	
	let connection: NWConnection
	let id: Int
	var mode: ConnectionMode
	
	var didStopCallback: ((Error?) -> Void)? = nil
	var handler: MessageDelegate
	
	init(nwConnection: NWConnection) {
		self.connection = nwConnection
		self.mode = .command
		self.id = ClientConnection.nextID
		self.handler = MessageHandler(clientID: id)
		
		ClientConnection.nextID += 1
	}
	
	func start() {
		print("Client id:\(id) will start")
		connection.stateUpdateHandler = self.stateDidChange(to:)
		setupReceive()
		connection.start(queue: .main)
	}
	
	func stop(error: Error?) {
		connection.stateUpdateHandler = nil
		connection.cancel()
		if let didStopCallback = didStopCallback {
			self.didStopCallback = nil
			didStopCallback(error)
		}
	}
	
	func stop() {
		self.stop(error: nil)
	}
	
	func send(data: Data?) {
		self.connection.send(
			content: data,
			completion: .contentProcessed({ error in
				if let error = error {
					self.connectionDidFail(error: error)
					return
				}
				print("Client id:\(self.id) did send")
			})
		)
	}
	
	private func changeMode(_ mode: ConnectionMode) {
		var message: String
		self.mode = mode
		switch self.mode {
		case .command:
			message = ServerMessage.enterCommandMode.description
		case .echo:
			message = ServerMessage.enterEchoMode.description
		case .personalChatting(let id):
			message = ServerMessage.enterPersonalChatting(id).description
		case .groupChatting(let id):
			message = ServerMessage.enterGroupChatting(id).description
		}
		
		self.send(data: message.data(using: .utf8))
	}
}

@available(macOS 10.14, *)
// MARK: Connection Setup
private extension ClientConnection {
	func stateDidChange(to state: NWConnection.State) {
		switch state {
		case .waiting(let error):
			connectionDidFail(error: error)
		case .ready:
			print("Client id:\(id) ready")
		case .failed(let error):
			connectionDidFail(error: error)
		default:
			break
		}
	}
	
	func setupReceive() {
		connection.receive(minimumIncompleteLength: 1, maximumLength: MTU) { [weak self] (data, _, isComplete, error) in
			guard let self = self else { return }
			
			if
				let data = data,
				!data.isEmpty,
				let message = String(data: data, encoding: .utf8) {
				
				print("connection id:\(self.id) did receive")
				var result: HandlerResultMode
				
				switch self.mode {
				case .command:
					result = self.handler.commandModeHandler(message)
				case .echo:
					result = self.handler.echoModeHandler(message)
				case .personalChatting(let id):
					result = self.handler.personalChattingModeHandler(message, id: id)
				case .groupChatting(let id):
					result = self.handler.groupChattingModeHandler(message, id: id)
				}
				resultDidComeFromHandler(result)
			}
			if isComplete {
				self.connectionDidEnd()
			} else if let error = error {
				self.connectionDidFail(error: error)
			} else {
				self.setupReceive()
			}
		}
	}
	
	func resultDidComeFromHandler(_ command: HandlerResultMode) {
		switch command {
		case .messageReturn(let data):
			self.send(data: data)
		case .errorReturn(let err):
			if let err = err {
				self.send(data: err)
			}
		case .modeChanged(let mode):
			self.changeMode(mode)
		case .modeDidFinishWithError(let err):
			self.send(data: err)
			self.changeMode(.command)
		case .clientDisconnet:
			self.stop()
		}
	}
	
	func connectionDidFail(error: Error) {
		print("Client id:\(id) did fail, error: \(error)")
		stop(error: error)
	}
	
	func connectionDidEnd() {
		print("Client id:\(id) did end")
		stop()
	}
}
