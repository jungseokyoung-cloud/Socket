//
//  ConnectionStorage.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

@available(macOS 10.14, *)
class ConnectionStorage {
	static let shared = ConnectionStorage()
	
	private let lock = NSLock()
	
	let maxGroupCount = 50
	var personal: Connections
	var group: [Connections]
	
	private init() {
		self.personal = Connections()
		self.group = [Connections](repeating: Connections(), count: maxGroupCount)
	}
	
	func removeAllConnection() {
		lock.lock(); defer {lock.unlock()}
		
		personal.connectionsByID.values.forEach { connection in
			connection.didStopCallback = nil
			connection.stop()
		}
		personal.removeAll()
		
		for (index, _) in group.enumerated() {
			group[index].removeAll()
		}
	}
}

@available(macOS 10.14, *)
// MARK: Personal Storage methods
extension ConnectionStorage {
	func addConnectionPersonal(_ connection: ClientConnection) {
		lock.lock(); defer {lock.unlock()}
		personal.connectionsByID[connection.id] = connection
	}
	
	func removeConnectionPersonal(_ connection: ClientConnection) {
		lock.lock(); defer {lock.unlock()}
		personal.connectionsByID.removeValue(forKey: connection.id)
	}
	
	func getPersonalByID(_ id: Int) -> ClientConnection? {
		return personal.connectionsByID[id]
	}
}

@available(macOS 10.14, *)
// MARK: Group Storage methods
extension ConnectionStorage {
	func addConnectionGroupAt(_ id: Int, connection: ClientConnection) {
		lock.lock(); defer {lock.unlock()}
		group[id].connectionsByID[connection.id] = connection
	}
	
	func getConnectionListGroupAt(_ id: Int) -> [Int: ClientConnection] {
		group[id].connectionsByID.forEach { (id, connection) in
			if personal.connectionsByID[id] == nil {
				removeConnectionPersonal(connection)
			}
		}
		
		return group[id].connectionsByID
	}
	
	func removeConnectionGroupAt(_ id: Int, clientID: Int) {
		lock.lock(); defer {lock.unlock()}
		group[id].connectionsByID.removeValue(forKey: clientID)
	}
	
	func getGroupList() -> [String] {
		var groupList = [String]()
		
		let groupConnections = group.map(\.connectionsByID)
		
		for (groupID, connections) in groupConnections.enumerated() {
			if !connections.isEmpty {
				groupList.append("\(groupID)")
			}
		}
		return groupList
	}
	
	func isvalidGroupID(_ id: Int) -> Bool {
		return id >= 0 && id < maxGroupCount
	}
}

@available(macOS 10.14, *)
struct Connections {
	var connectionsByID: [Int: ClientConnection] = [:]
	
	mutating func removeAll() {
		self.connectionsByID.removeAll()
	}
}
