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
	var handler: CommandDelegate
	
	init(nwConnection: NWConnection) {
		self.connection = nwConnection
		self.mode = .echo
		self.id = ClientConnection.nextID
		self.handler = CommandHandler()
		
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
	
	private func changeMode(_ mode: ConnectionMode) { }
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
			
			if let data = data, !data.isEmpty {
				let message = String(data: data, encoding: .utf8)
				print("connection id:\(self.id) did receive")
				var result: CommandMode
				
				switch self.mode {
				case .echo:
					result = self.handler.echoModeHandler(message: message)
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
	
	func resultDidComeFromHandler(_ command: CommandMode) {
		switch command {
		case .messageReturn(let data):
			self.send(data: data)
		case .modeChanged(let mode):
			self.changeMode(mode)
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
