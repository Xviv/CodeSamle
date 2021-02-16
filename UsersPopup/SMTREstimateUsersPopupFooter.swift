//
//  SMTREstimateUsersPopupFooter.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import UIKit
import SmetterCore

internal class SMTREstimateUsersPopupFooter: UIView {
	
	internal private(set) var button: UIButton!

	internal var buttonTouched: (() -> Void)?

	internal override init(frame: CGRect) {
		super.init(frame: frame)
		self.button = UIButton(type: .custom)
		self.button.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(button)
		self.button.pinEdges(to: self, with: .zero)
		self.button.contentHorizontalAlignment = .left
		self.button.setImage(UIImage.Common.addCircleGray, for: .normal)
		self.button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		self.button.setTitleColor(.azure, for: .normal)
		self.button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
		self.button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
		self.button.addTarget(self, action: #selector(buttonTouchedUpInside), for: .touchUpInside)
	}

	@objc
	internal func buttonTouchedUpInside() {
		self.buttonTouched?()
	}

	@available(*, unavailable, message: "init (coder:) is not implemented")
	internal required init?(coder aDecoder: NSCoder) {
		SMTRNotImplemented();
	}
}
