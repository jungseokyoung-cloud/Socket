//
//  File.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

enum CommandError: Error {
	case unkownCommand
}

extension CommandError {
	var description: String {
		switch self {
		case .unkownCommand:
			return "Unkown commend. See 'option'".appendCRLF
		}
	}
}
