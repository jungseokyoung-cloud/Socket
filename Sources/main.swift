// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

if #available(macOS 10.14, *) {
	
	func initServer(port: UInt16) {
		let server = Server(port: port)
		try? server.start()
	}
	
	initServer(port: 8080)
	
	RunLoop.current.run()
}
