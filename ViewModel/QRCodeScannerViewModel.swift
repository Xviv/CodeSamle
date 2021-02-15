//
//  QRCodeScannerViewModel.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation

internal protocol QRCodeScannerViewModelProtocol {
	func performRequest(
		qrCodeData: String,
		comment: String?,
		completion: @escaping (SMTRNetworkResult<String>) -> Void
	)
	
	func viewDidDismiss()
}

internal class QRCodeScannerBaseViewModel: QRCodeScannerViewModelProtocol {
	
	// MARK: - Internal properties
	
	internal let service: SMTREstimateService
	internal let estimateId: Int
	internal weak var delegate: SMTRChildViewModelDelegate?
	
	// MARK: - Initialization
	
	internal init(
		service: SMTREstimateService,
		estimateId: Int,
		delegate: SMTRChildViewModelDelegate? = nil
	) {
		self.service = service
		self.estimateId = estimateId
		self.delegate = delegate
	}
	
	// MARK: - Internal methods
	
	internal func performRequest(
		qrCodeData: String,
		comment: String? = nil,
		completion: @escaping (SMTRNetworkResult<String>) -> Void
	) {
		// OVERRIDE
	}
	
	internal func viewDidDismiss() {
		self.delegate?.childDidRequestReloadData()
	}
}

internal final class QRCodeScannerPurchaseViewModel: QRCodeScannerBaseViewModel {
	
	// MARK: - Internal methods
	
	internal override func performRequest(
		qrCodeData: String,
		comment: String? = nil,
		completion: @escaping (SMTRNetworkResult<String>) -> Void
	) {
		self.service.sendPurchaseReceipt(
			with: self.estimateId,
			qrCodeData: qrCodeData,
			comment: comment
		) { (response: SMTRNetworkResult<SMTRScanQRCodeResponse>) in
				switch response {
				case .failure(let error):
					completion(.failure(error))
				case .success(let qrCodeResponse):
					completion(.success(qrCodeResponse.message))
				}
		}
	}
}

internal final class QRCodeScannerWorkViewModel: QRCodeScannerBaseViewModel {
	
	// MARK: - Private properties
	
	private let subcontractorId: Int?
	
	// MARK: - Initialization
	
	internal init(
		service: SMTREstimateService,
		estimateId: Int,
		subcontractorId: Int?,
		delegate: SMTRChildViewModelDelegate? = nil
	) {
		self.subcontractorId = subcontractorId
		super.init(service: service, estimateId: estimateId, delegate: delegate)
	}
	
	// MARK: - Internal methods
	
	internal override func performRequest(
		qrCodeData: String,
		comment: String? = nil,
		completion: @escaping (SMTRNetworkResult<String>) -> Void
	) {
		self.service.sendWorkReceipt(
			with: self.estimateId,
			qrCodeData: qrCodeData,
			subcontractorId: self.subcontractorId,
			comment: comment
		) { (response: SMTRNetworkResult<SMTRScanQRCodeResponse>) in
				switch response {
				case .failure(let error):
					completion(.failure(error))
				case .success(let qrCodeResponse):
					completion(.success(qrCodeResponse.message))
				}
		}
	}
}
