//
//  SMTREstimateUsersPopupVM.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal class SMTREstimateUsersPopupVM: SMTREstimateUsersPopupVMProtocol {

	// MARK: - private properties
	
	private var users = [SMTREstimateUser]()

	private var cellVMs = [SMTREstimateUsersPopupCellVMProtocol]()

	private var usersRole: SMTREstimateUserRole

	// MARK: - public properties

	internal weak var delegate: SMTREstimateUsersPopupDelegate?

	internal weak var VMDelegate: SMTREstimateUsersPopupVMDelegate?

	internal var title = SMTRObservable<String>()
	
	internal var numberOfSection = SMTRObservable<Int>(value: 1)
	
	internal func numberOfRows(in section: Int) -> Int {
		return self.cellVMs.count
	}
	
	internal func VMFor(indexPath: IndexPath) -> SMTREstimateUsersPopupCellVMProtocol {
		return self.cellVMs[indexPath.row]
	}
	
	internal var newUserButtonHidden = SMTRObservable<Bool>()

	internal var newUserButtonTitle: SMTRObservable<String>

	// MARK: - initialization

	internal init(
			estimateInfo: SMTREstimateInfo,
			usersRole: SMTREstimateUserRole,
			currentUserRoles: [SMTREstimateUserRole],
			currentType: SMTREstimateType,
			VMDelegate: SMTREstimateUsersPopupVMDelegate) {

		self.usersRole = usersRole

		self.users = estimateInfo.users[usersRole] ?? []

		self.VMDelegate = VMDelegate
        
		self.cellVMs = self.users.map { SMTREstimateUsersPopupCellVM(user: $0, isReadOnly: false, isSelectable: false) }
       
		self.newUserButtonHidden.value = false

		self.newUserButtonTitle = SMTRObservable(value: "add-user-button-title".localized(table: .estimate))
		self.title.value = usersRole.popupTitle
	}

	// MARK: - private methods

	internal func didPressDeleteUser(at indexPath: IndexPath) {
		let user = self.users[indexPath.row]

		let message = "user.remove-user-message".localized(table: .estimate, arguments: [user.name])

		let alertVM = SMTRAlertViewModel(title: "user.remove-user-title".localized(table: .estimate), message: message, actions: [
			SMTRAlertViewModel.Action.plain(title: "delete".localized(table: .common)) { [weak self] in
				guard let self = self else {
					return
				}
				
				self.VMDelegate?.didPressRemoveUser(user: user, for: self.usersRole) { [weak self] error in
					if error == nil {
						self?.delegate?.dismiss()
					}
				}
			},
		])
		self.delegate?.presentAlert(with: alertVM)
	}

	internal func didPressAddUser() {
		self.VMDelegate?.didPressAddUser(for: self.usersRole)
	}

	internal func didSelectUser(at indexPath: IndexPath) {
		// Currently does nothing in this VM
	}
}

fileprivate extension SMTREstimateUserRole {
	var popupTitle: String {
		switch self {
		case .manager:
			return "role.managers".localized(table: .estimate)
		case .purchaseAgent:
			return "role.purchaseAgents".localized(table: .estimate)
		case .performer:
			return "role.performers".localized(table: .estimate)
		case .customer:
			return "role.customers".localized(table: .estimate)
		case .subcontractor:
			assertionFailure("Role '\(self)' is not intended to be used in the UI")
			return "role.subcontractor".localized(table: .estimate)
		}
	}
}
