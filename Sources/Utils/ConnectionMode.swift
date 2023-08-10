//
//  ConnectionMode.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum ConnectionMode {
	case command
	case echo
	case personalChatting(_ id: Int)
}
