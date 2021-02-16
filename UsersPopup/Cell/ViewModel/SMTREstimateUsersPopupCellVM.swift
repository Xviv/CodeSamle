//
//  SMTREstimateUsersPopupCellVM.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal class SMTREstimateUsersPopupCellVM: SMTREstimateUsersPopupCellVMProtocol {
	internal let isReadOnly: Bool
	internal let isSelectable: Bool
	internal let name: String
	internal let imageURL: URL?
	internal let email: String

	internal init(user: SMTREstimateUser, isReadOnly: Bool, isSelectable: Bool) {
		self.isReadOnly = isReadOnly
		self.isSelectable = isSelectable
		self.name = user.name
		self.imageURL = user.imageURL
		self.email = user.email.uppercased()
	}
}
