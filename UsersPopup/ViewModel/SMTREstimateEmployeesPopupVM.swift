//
//  SMTREstimateEmployeesPopupVM.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal final class SMTREstimateEmployeesPopupVM: SMTREstimateUsersPopupVMProtocol {
	
	// MARK: - Internal properties

	internal let title: SMTRObservable<String>
	internal let numberOfSection: SMTRObservable<Int>
	internal let newUserButtonHidden: SMTRObservable<Bool>
	internal let newUserButtonTitle: SMTRObservable<String>
	
	internal weak var delegate: SMTREstimateUsersPopupDelegate?
	internal weak var VMDelegate: SMTREstimateUsersPopupVMDelegate?

	// MARK: - Private properties
	
	private let cachedEmployees: [SMTRProjectEmployee]
	private let usersRole: SMTREstimateUserRole

	// MARK: - Initialization/Deinitialization
	
	internal init(
		availableEmployees: [SMTRProjectEmployee],
		usersRole: SMTREstimateUserRole
	) {
		self.cachedEmployees = availableEmployees
		self.usersRole = usersRole
        self.title = SMTRObservable(value: usersRole.popupTitle)
		self.numberOfSection = SMTRObservable(value: 1)
		self.newUserButtonHidden = SMTRObservable(value: false)
		self.newUserButtonTitle = SMTRObservable(value: "add-employee-button-title".localized(table: .estimate))
	}
	
	// MARK: - Internal methods
	
	internal func numberOfRows(in section: Int) -> Int {
		return self.cachedEmployees.count
	}
	
	internal func VMFor(indexPath: IndexPath) -> SMTREstimateUsersPopupCellVMProtocol {
		let user = self.cachedEmployees[indexPath.row]

		return SMTREstimateUsersPopupCellVM(user: user, isReadOnly: true, isSelectable: true)
	}
	
	internal func didPressAddUser() {
		self.VMDelegate?.didPressCreateUser(for: self.usersRole) { [weak self] error in
			if error == nil {
				self?.delegate?.dismiss()
			}
		}
	}
	
	internal func didSelectUser(at indexPath: IndexPath) {
		let user = self.cachedEmployees[indexPath.row]

		self.VMDelegate?.didPressSelectUser(user: user, for: self.usersRole) { [weak self] error in
			if error == nil {
				self?.delegate?.dismiss()
			}
		}
	}
	
	internal func didPressDeleteUser(at indexPath: IndexPath) {
		// Currently does nothing in this VM
	}
}

fileprivate extension SMTREstimateUserRole {
    var popupTitle: String {
        switch self {
        case .manager:
            return "role.choose.managers".localized(table: .estimate)
        case .purchaseAgent:
            return "role.choose.purchaseAgents".localized(table: .estimate)
        case .performer:
            return "role.choose.performers".localized(table: .estimate)
        case .customer:
            return "role.choose.customers".localized(table: .estimate)
        case .subcontractor:
            assertionFailure("Role '\(self)' is not intended to be used in the UI")
            return "role.choose.subcontractor".localized(table: .estimate)
        }
    }
}
