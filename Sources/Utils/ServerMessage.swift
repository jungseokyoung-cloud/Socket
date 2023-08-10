//
//  ServerMessage.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum ServerMessage {
	case welcomeMessage(_ id: Int)
	case enterCommandMode
	case enterEchoMode
	case option
	case enterPersonalChatting(_ id: Int)
}

extension ServerMessage {
	var description: String {
		switch self {
		case .welcomeMessage(let id):
			return "You are connection: \(id)".appendCRLF
			
		case .enterCommandMode:
			return "-------- COMMAND MODE --------".appendCRLF
			
		case .enterEchoMode:
			return "-------- ECHO MODE --------".appendCRLF
			
		case .enterPersonalChatting(let id):
			return "-------- CHAT MODE --------\nYou Can Chat With With id:\(id)".appendCRLF
			
		case .option:
			return """
	--------------------------------------
	< OPTION >
	Client ID List: Type 'clientlist'
	Group ID List: Type 'grouplist'
	Echo mode: Type 'echo'
	Group Chatting: Type 'group <GrouID>'
	Personal Chatting: Type 'chat <ID>'
	Option List: Type 'option'
	Exit: Type 'Exit'
	--------------------------------------
	""".appendCRLF
		}
	}
}
