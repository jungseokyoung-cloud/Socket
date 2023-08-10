//
//  ConnectionStorage.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

@available(macOS 10.14, *)
struct ConnectionStorage {
	static var personal = Connections()
	static var group = [Connections](repeating: Connections(), count: maxGroupCount)
	static var maxGroupCount = 50
	
	static func removeAllConnection() {
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
	static func addConnectionPersonal(_ connection: ClientConnection) {
		personal.connectionsByID[connection.id] = connection
	}
	
	static func removeConnectionPersonal(_ connection: ClientConnection) {
		personal.connectionsByID.removeValue(forKey: connection.id)
	}
	
	static func getPersonalByID(_ id: Int) -> ClientConnection? {
		return personal.connectionsByID[id]
	}
}

@available(macOS 10.14, *)
// MARK: Group Storage methods
extension ConnectionStorage {
	static func addConnectionGroupAt(_ id: Int, connection: ClientConnection) {
		group[id].connectionsByID[connection.id] = connection
	}
	
	static func getConnectionListGroupAt(_ id: Int) -> [Int: ClientConnection] {
		group[id].connectionsByID.forEach { (id, connection) in
			if personal.connectionsByID[id] == nil {
				removeConnectionPersonal(connection)
			}
		}
		
		return group[id].connectionsByID
	}
	
	static func removeConnectionGroupAt(_ id: Int, clientID: Int) {
		group[id].connectionsByID.removeValue(forKey: clientID)
	}
	
	static func getGroupList() -> [String] {
		var groupList = [String]()
		
		let groupConnections = group.map(\.connectionsByID)
		
		for (groupID, connections) in groupConnections.enumerated() {
			if !connections.isEmpty {
				groupList.append("\(groupID)")
			}
		}
		return groupList
	}
	
	static func isvalidGroupID(_ id: Int) -> Bool {
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
