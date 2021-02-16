//
//  SMTREstimateUsersPopupCell.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import UIKit
import SmetterCore
import SDWebImage

internal class SMTREstimateUsersPopupCell: UITableViewCell, SMTRReusable {

	// MARK: - Constants
	
	private enum Constants {
		static let userImageWidth: CGFloat = 32
		static let userImageHeight: CGFloat = 32
		static let userImageLeadingOffset: CGFloat = 24
		static let userImageTrailingOffset: CGFloat = 16
		static let creatorTopOffset: CGFloat = 8
		static let nameTopOffset: CGFloat = 18
		static let emailToName: CGFloat = 4
		static let deleteButtonWidth: CGFloat = 47
	}

	// MARK: - Private properties
	
	private var nameLabel: UILabel!
	private var emailLabel: UILabel!
	private var userImageView: UIImageView!
	private var deleteButton: UIButton!

	// MARK: - Public properties

	internal weak var delegate: SMTREstimateUsersPopupCellDelegate?

	// MARK: - Initialization

	internal override init(style: CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.setupUI()
	}

	@available (*, unavailable, message: "init (coder:) is not implemented")
	internal required init? (coder aDecoder: NSCoder) {
		SMTRNotImplemented ();
	}
	
	// MARK: - Public methods
	
	internal override func prepareForReuse() {
		super.prepareForReuse()
		self.userImageView.sd_cancelCurrentAnimationImagesLoad()
		self.userImageView.image = UIImage.Profile.noAvatar
	}

	// MARK: - Private API

	private func setupUI() {
		setupUserImageView()
		setupDeleteButton()
		setupNameLabel()
		setupEmailLabel()
	}

	private func setupUserImageView() {
		self.userImageView = UIImageView(image: UIImage.Profile.noAvatar)
		self.userImageView.translatesAutoresizingMaskIntoConstraints = false
		self.userImageView.contentMode = .scaleAspectFill
		self.userImageView.cornerRadius = Constants.userImageWidth / 2
		self.contentView.addSubview(self.userImageView)
		NSLayoutConstraint.activate([
			self.userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageWidth),
			self.userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageWidth),
			self.userImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.userImageLeadingOffset),
			self.userImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
		])
	}

	private func setupDeleteButton() {
		self.deleteButton = UIButton(type: .custom)
		self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
		self.deleteButton.setImage(.commonDarkDelete, for: .normal)
		self.deleteButton.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
		self.contentView.addSubview(self.deleteButton)

		NSLayoutConstraint.activate([
			self.deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.deleteButton.widthAnchor.constraint(equalToConstant: Constants.deleteButtonWidth),
			self.deleteButton.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.deleteButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
		])
	}

	private func setupNameLabel() {
		self.nameLabel = UILabel()
		self.nameLabel.font = .systemFont(ofSize: 15)
		self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.nameLabel)

		NSLayoutConstraint.activate([
			self.nameLabel.leadingAnchor.constraint(equalTo: self.userImageView.trailingAnchor, constant: Constants.userImageTrailingOffset),
			self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.nameTopOffset),
			self.nameLabel.trailingAnchor.constraint(equalTo: self.deleteButton.leadingAnchor, constant: 0),
		])
	}

	private func setupEmailLabel() {
		self.emailLabel = UILabel()
		self.emailLabel.font = .systemFont(ofSize: 11)
		self.emailLabel.textColor = .black40
		self.emailLabel.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.emailLabel)

		NSLayoutConstraint.activate([
			self.emailLabel.leadingAnchor.constraint(equalTo: self.userImageView.trailingAnchor, constant: Constants.userImageTrailingOffset),
			self.emailLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: Constants.emailToName),
			self.emailLabel.trailingAnchor.constraint(equalTo: self.deleteButton.leadingAnchor, constant: 0),
		])
	}

	@objc internal func deleteButtonTouched() {
		self.delegate?.deleteButtonTouched(cell: self)
	}
}

extension SMTREstimateUsersPopupCell: SMTRConfigurable {
	internal typealias Model = SMTREstimateUsersPopupCellVMProtocol
	
	internal func configure(with model: SMTREstimateUsersPopupCellVMProtocol) -> Self {
		self.selectionStyle = model.isSelectable ? .default : .none
		self.deleteButton.isHidden = model.isReadOnly
		self.nameLabel.text = model.name
		self.userImageView.sd_setImage(with: model.imageURL, placeholderImage: UIImage.Profile.noAvatar)
		self.emailLabel.text = model.email
		return self
	}
}

internal protocol SMTREstimateUsersPopupCellDelegate: AnyObject {
	
	func deleteButtonTouched(cell: SMTREstimateUsersPopupCell)
}
