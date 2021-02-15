//
//  QRCodeScannerVC.swift
//  Copyright © 2020 Smetter. All rights reserved.
//

import Foundation
import AVFoundation
import SmetterUI
import SmetterCore
import CPCommon

internal final class SMTRQRCodeScannerVC: SMTRBaseVC, SMTRBaseVCProtocol {
	
	// MARK: - Outlets/UI
	
	// MARK: - Private properties
	
	private var captureSession: AVCaptureSession?
	private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
	private weak var cameraAreaView: UIView!
	
	private var viewModel: QRCodeScannerViewModelProtocol
	
	// MARK: - Initialization
	
	internal init(viewModel: QRCodeScannerViewModelProtocol) {
		self.viewModel = viewModel
		
		super.init(nibName: "SMTRQRCodeScannerVC", bundle: nil)
	}
	
	@available (*, unavailable, message: "init (coder:) is not implemented")
	internal required init? (coder aDecoder: NSCoder) {
		SMTRNotImplemented ();
	}
	
	// MARK: - Internal methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupCaptureSession()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		captureSession?.startRunning()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
        self.setupPreviewLayer()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.viewModel.viewDidDismiss()
	}
	
	// MARK: - Private methods
	
	private func setupCaptureSession() {
		self.captureSession = AVCaptureSession()
		var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInWideAngleCamera, .builtInTelephotoCamera]
		
		if #available(iOS 13.0, *) {
			deviceTypes += [.builtInTripleCamera, .builtInDualWideCamera, .builtInUltraWideCamera]
		}
		
		let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
			deviceTypes: deviceTypes,
			mediaType: AVMediaType.video,
			position: .back
		)
		
		guard let captureDevice = deviceDiscoverySession.devices.first else {
            SMTRLoggingService.log("Failed to get the camera device", atLevel: .fault)
			return
		}
		
		do {
			let input = try AVCaptureDeviceInput(device: captureDevice)
			captureSession?.addInput(input)
			
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession?.addOutput(captureMetadataOutput)
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
			
		} catch {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
				self.showCameraError()
			}
			return
		}
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		view.layer.insertSublayer(videoPreviewLayer!, at: 0)
		
		captureSession?.startRunning()
	}
    
    private func setupPreviewLayer() {
        guard let previewLayerConnection = self.videoPreviewLayer?.connection else {
            return
        }
        
        let currentDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        if previewLayerConnection.isVideoOrientationSupported {
            switch (orientation) {
            case .portrait:
                previewLayerConnection.videoOrientation = .portrait
            case .landscapeRight:
                previewLayerConnection.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                previewLayerConnection.videoOrientation = .landscapeRight
            case .portraitUpsideDown:
                previewLayerConnection.videoOrientation = .portraitUpsideDown
            default:
                previewLayerConnection.videoOrientation = .portrait
            }
        }
        
        self.videoPreviewLayer?.frame = self.view.bounds
    }
	
	@IBAction
	private func cancelButtonTapped(_ sender: UIButton) {
		self.close()
	}
	
	private func close() {
		self.dismiss()
	}
	
	private func openSettings() {
		UIApplication.shared.openSettings()
	}
	
	private func showCameraError() {
		let cancelAction = SMTRAlertAction(title: "cancel".localized(table: .common)) { [weak self] alertVC in
			alertVC.dismiss {
				self?.close()
			}
		}
		
		let settingsAction = SMTRAlertAction(title: "settings-title".localized(table: .qrcode)) { [weak self] alertVC in
			alertVC.dismiss {
				self?.openSettings()
			}
		}
		
		let controller = SMTRAlertController(
			title: "camera-error-title".localized(table: .qrcode),
			image: nil,
			message: "camera-error-subtitle".localized(table: .qrcode),
			attributedMessage: nil,
			fields: [],
			actions: [cancelAction, settingsAction],
			buttonsOrientation: .horizontal
		)
		self.present(controller)
	}
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension SMTRQRCodeScannerVC: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(
		_ output: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from connection: AVCaptureConnection
	) {
		captureSession?.stopRunning()
		let metadataObj = metadataObjects[safe: 0] as? AVMetadataMachineReadableCodeObject
		guard let resultString = metadataObj?.stringValue else {
			return
		}
		
		self.showCommentAlert(using: resultString)
	}
	
	private func sendReceipt(qrCodeData: String, comment: String?) {
		self.viewModel.performRequest(
			qrCodeData: qrCodeData,
			comment: comment
		) { [weak self] response in
			self?.handleServerResponse(response)
		}
	}
	
	private func showCommentAlert(using qrCodeData: String) {
		let addCommentTitle = "photos.add-comment-done-action".localized(table: .project)
		let addCommentAction = SMTRAlertViewModel.Action.withInput(title: addCommentTitle) { [weak self] comment in
			self?.sendReceipt(qrCodeData: qrCodeData, comment: comment)
		}

		let alertViewModel = SMTRAlertViewModel(
			title: "add-comment-title".localized(table: .qrcode),
            message: .empty,
			actions: [addCommentAction]
		)
		
		let actions = alertViewModel.actions.map {
			SMTRAlertAction(viewModel: $0)
		}
		
		let alert = SMTRAlertController(
			title: alertViewModel.title,
			image: nil,
			message: alertViewModel.message,
			attributedMessage: nil,
			fields: [.empty()],
			actions: actions,
			buttonsOrientation: .horizontal
		) { [weak self] in
			self?.captureSession?.startRunning()
		}
		
		self.present(alert)
	}
	
	private func handleServerResponse(_ response: SMTRNetworkResult<String>) {
		switch response {
		case .failure(let error):
			self.present(error: error)
		case .success(let message):
			self.showSuccessAlert(message: message)
		}
	}
	
	private func showSuccessAlert(message: String) {
		let finalMessage: String = message.isEmpty ? "success-title".localized(table: .qrcode) : message
		let okAction = SMTRAlertAction(title: "okay-button".localized(table: .qrcode)) { [weak self] alert in
			alert.dismiss {
				self?.close()
			}
		}
		
		let alertController = SMTRAlertController(
			title: nil,
			image: nil,
			message: finalMessage,
			attributedMessage: nil,
			fields: [],
			actions: [okAction],
			buttonsOrientation: .horizontal
		)
		
		self.present(alertController)
	}
}
