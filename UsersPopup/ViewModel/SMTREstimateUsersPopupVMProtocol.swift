//
//  SMTREstimateUsersPopupVMProtocol.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal protocol SMTREstimateUsersPopupVMProtocol {
	var delegate: SMTREstimateUsersPopupDelegate? { get set }
	var title: SMTRObservable<String> { get }
	var numberOfSection: SMTRObservable<Int> { get }
	var newUserButtonHidden: SMTRObservable<Bool> { get }
	var newUserButtonTitle: SMTRObservable<String> { get }
	
	func numberOfRows(in section: Int) -> Int
	func VMFor(indexPath: IndexPath) -> SMTREstimateUsersPopupCellVMProtocol
	func didPressAddUser()
	func didPressDeleteUser(at indexPath: IndexPath)
	func didSelectUser(at indexPath: IndexPath)
}

internal protocol SMTREstimateUsersPopupDelegate: SMTRVMLoadingDelegate {
	func dismiss()
	func presentAlert(with viewModel: SMTRAlertViewModel)
	func reloadData()
}

internal protocol SMTREstimateUsersPopupVMDelegate: SMTRChildViewModelDelegate {
	/// Called in step #1 by tapping on 'Кнопка "Добавить пользователя"'.
	/// Also may be called from estimate screen with default role for the type of the estimate.
	func didPressAddUser(for role: SMTREstimateUserRole)

	/// Called in step #1 by tapping on 'Кнопка "Удалить пользователя"'.
	func didPressRemoveUser(
		user: SMTREstimateUser,
		for role: SMTREstimateUserRole,
		completion: ((_ error: Error?) -> Void)?
	)

	/// Called in step #2 when employee selected.
	func didPressSelectUser(
		user: SMTREstimateUser,
		for role: SMTREstimateUserRole,
		completion: ((_ error: Error?) -> Void)?
	)

	/// Called in step #1 by tapping on 'Кнопка "Добавить пользователя"' ONLY if role of new user - `customer`.
	/// Otherwise, called in step #2 by tapping on 'Кнопка "Добавить сотрудника"'.
	func didPressCreateUser(
		for role: SMTREstimateUserRole,
		completion: ((_ error: Error?) -> Void)?
	)
}
