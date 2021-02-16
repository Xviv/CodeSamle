//
//  SMTREstimateUsersPopupVC.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import UIKit
import SmetterCore
import SmetterUI

internal class SMTREstimateUsersPopupVC: SMTRBaseVC {

	private enum Constants {
		static let cornerRadius: CGFloat = 16
		static let titleVerticalOffset: CGFloat = 24
		static let tableVerticalOffset: CGFloat = 76
		static let rowHeight: CGFloat = 72
		static let maxRows: CGFloat = 4 //includes "Add user" footer that is the same height as the rows
	}
	
	internal override var preferredContentSize: CGSize {
		set {
			SMTRLoggingService.log(message: "Setter for property \(#function) disabled.", atLevel: .debug)
		}
		get {
			let layoutSize: CGSize = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let maxHeight = min(layoutSize.height, UIScreen.main.bounds.height * 0.7)
			return CGSize(width: CGFloat.expandedContentMetric, height: maxHeight + Constants.titleVerticalOffset)
		}
	}

	private var tableView: UITableView!
	private var footer: SMTREstimateUsersPopupFooter!
	private var titleLabel: UILabel!
	
	private var viewModel: SMTREstimateUsersPopupVMProtocol
	
	internal init(viewModel: SMTREstimateUsersPopupVMProtocol) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.viewModel.delegate = self
		self.modalPresentationStyle = .custom
	}
	
	@available (*, unavailable, message: "init (coder:) is not implemented")
	internal required init? (coder aDecoder: NSCoder) {
		SMTRNotImplemented ();
	}
	
	internal override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.bindUI()
	}
	
	internal func setupUI() {
		self.view.cornerRadius = Constants.cornerRadius
		self.view.backgroundColor = .whiteBackground
		self.setupTitleLabel()
		self.setupTableView()
	}

	private func setupTitleLabel() {
		self.titleLabel = UILabel()
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
		self.view.addSubview(self.titleLabel)
		self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Constants.titleVerticalOffset).isActive = true
	}
	
	private func setupTableView() {
		self.tableView = SMTRSelfSizingTableView(frame: .zero, style: .plain)
		self.tableView.register(SMTREstimateUsersPopupCell.self)
		self.tableView.separatorStyle = .none
		self.tableView.backgroundColor = .clear
		self.tableView.rowHeight = Constants.rowHeight
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.alwaysBounceVertical = false
		self.tableView.bounces = true
		self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.cornerRadius, right: 0)
		self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: Constants.cornerRadius, right: 0)

		self.footer = SMTREstimateUsersPopupFooter(frame: CGRect(width: self.view.frame.width, height: Constants.rowHeight))
		self.footer.buttonTouched = { [weak self] in
			self?.dismissAnimated()
			self?.viewModel.didPressAddUser()
		}
		self.tableView.tableFooterView = nil

		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.tableView)
		self.tableView.pinEdges(to: self.view, with: UIEdgeInsets(top: Constants.tableVerticalOffset, left: 0, bottom: 0, right: 0))
		self.tableView.layoutIfNeeded()
	}

	internal func bindUI() {
		self.titleLabel.bind(to: self.viewModel.title)
		self.footer.button.bind(to: self.viewModel.newUserButtonTitle)
		self.viewModel.newUserButtonHidden.bind { [weak self] _, newValue in
			self?.tableView.tableFooterView = (newValue ?? false) ? nil : self?.footer
		}
	}
}

extension SMTREstimateUsersPopupVC: SMTREstimateUsersPopupCellDelegate {
	internal func deleteButtonTouched(cell: SMTREstimateUsersPopupCell) {
		guard let indexPath = self.tableView.indexPath(for: cell) else {
			assertionFailure()
			return
		}

		self.viewModel.didPressDeleteUser(at: indexPath)
	}
}

extension SMTREstimateUsersPopupVC: UITableViewDelegate, UITableViewDataSource {

	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.numberOfRows(in: section)
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: SMTREstimateUsersPopupCell = tableView.dequeueReusableCell(for: indexPath)
		cell.delegate = self
		return cell.configure(with: self.viewModel.VMFor(indexPath: indexPath))
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.viewModel.didSelectUser(at: indexPath)
	}
}

extension SMTREstimateUsersPopupVC: SMTREstimateUsersPopupDelegate {
	internal func presentAlert(with viewModel: SMTRAlertViewModel) {
		self.present(SMTRAlertController(viewModel: viewModel))
	}

	internal func reloadData() {
		self.tableView?.reloadData()
	}
}
