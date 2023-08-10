//
//  File.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum CommandError: Error {
	case unkownCommand
	case invalidClientID(_ id: Int)
}

extension CommandError {
	var description: String {
		switch self {
		case .unkownCommand:
			return "Unkown commend. See 'option'".appendCRLF
			
		case .invalidClientID(let id):
			return "Client id: \(id) is invalid. See 'clientlist'".appendCRLF
		}
	}
}
