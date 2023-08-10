//
//  File.swift
//  
//
//  Created by jung on 2023/08/10.
//

import Foundation

extension String {
	var removeCRLF: String {
		self.replacingOccurrences(of: "\r\n", with: "")
	}
	
	var appendCRLF: String {
		self + "\r\n"
	}
}
