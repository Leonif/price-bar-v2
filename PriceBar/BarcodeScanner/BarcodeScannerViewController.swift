//
//  BarcodeScannerViewController.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import UIKit
import AVFoundation

final class BarcodeScannerViewController: BaseHostingController<BarcodeScannerView> {
    private let captureSession: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let viewModel: BarcodeScannerViewModel
    
    init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
        self.captureSession = AVCaptureSession()
        super.init(rootView: BarcodeScannerView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
            
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            } else {
                self.showError()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417] // Выберите нужные типы штрих-кодов
            } else {
                self.showError()
                return
            }
            
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.previewLayer)
                
            }
            self.captureSession.startRunning()
        }
    }

    func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Не удалось настроить сканер штрих-кодов", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            viewModel.completedSubject.send(stringValue)
        }
    }
}

