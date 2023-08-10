//
//  Server.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation
import Network

@available(macOS 10.14, *)
class Server {
	let port: NWEndpoint.Port
	let listener: NWListener
	
	init(port: UInt16) {
		self.port = NWEndpoint.Port(rawValue: port)!
		listener = try! NWListener(using: .tcp, on: self.port)
	}
	
	func start() throws {
		print("----- Server starting -----")
		listener.stateUpdateHandler = self.stateDidChange(to:)
		listener.newConnectionHandler = self.didAccept(nwConnection:)
		listener.start(queue: .main)
	}
	
	func stateDidChange(to newState: NWListener.State) {
		switch newState {
		case .ready:
			print("Server ready.")
		case .failed:
			exit(EXIT_FAILURE)
		default:
			break
		}
	}
	
	private func didAccept(nwConnection: NWConnection) {
		let connection = ClientConnection(nwConnection: nwConnection)
		ConnectionStorage.addConnectionPersonal(connection)
		connection.didStopCallback = { _ in
			ConnectionStorage.removeConnectionPersonal(connection)
			print("server did close connection \(connection.id)")
		}
		connection.start()
		
		let connectionMessage = ServerMessage.welcomeMessage(connection.id).description
		connection.send(data: connectionMessage.data(using: .utf8))
		
		let optionMessage = ServerMessage.option.description
		connection.send(data: optionMessage.data(using: .utf8))
		print("Server did open connection \(connection.id)")
	}
		
	private func stop() {
		self.listener.stateUpdateHandler = nil
		self.listener.newConnectionHandler = nil
		self.listener.cancel()
		
		ConnectionStorage.removeAllConnection()
	}
}
