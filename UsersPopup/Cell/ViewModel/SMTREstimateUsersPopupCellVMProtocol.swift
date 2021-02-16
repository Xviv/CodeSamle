//
//  SMTREstimateUsersPopupCellVMProtocol.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal protocol SMTREstimateUsersPopupCellVMProtocol {
	var isReadOnly: Bool { get }
	var isSelectable: Bool { get }
	var name: String { get }
	var imageURL: URL? { get }
	var email: String { get }
}
