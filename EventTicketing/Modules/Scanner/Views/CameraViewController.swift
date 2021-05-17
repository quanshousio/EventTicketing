//
//  CameraViewController.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/14/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//
//  Based on Apple's sample code called AVCam: Building a Camera App

import AVFoundation
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

protocol CameraViewControllerDelegate: AnyObject {
  func cameraDidFindStringFromMetadataObject(
    _ cameraViewController: CameraViewController,
    string: String
  )
}

#if !os(macOS)
class CameraPreviewView: UXView {
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let layer = layer as? AVCaptureVideoPreviewLayer else {
      fatalError("[Camera] videoPreviewLayer is not AVCaptureVideoPreviewLayer")
    }
    return layer
  }

  var session: AVCaptureSession? {
    get { videoPreviewLayer.session }
    set { videoPreviewLayer.session = newValue }
  }

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }
}
#else
class CameraPreviewView: UXView, CALayerDelegate {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    commonInit()
  }

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    commonInit()
  }

  private func commonInit() {
    wantsLayer = true
  }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let layer = layer as? AVCaptureVideoPreviewLayer else {
      fatalError("[Camera] videoPreviewLayer is not AVCaptureVideoPreviewLayer")
    }
    return layer
  }

  var session: AVCaptureSession? {
    get { videoPreviewLayer.session }
    set { videoPreviewLayer.session = newValue }
  }

  override func makeBackingLayer() -> CALayer {
    let layer = AVCaptureVideoPreviewLayer()
    layer.delegate = self
    layer.needsDisplayOnBoundsChange = true
    return layer
  }
}
#endif

class CameraViewController: UXViewController {
  private enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
  }

  @objc private dynamic var videoDeviceInput: AVCaptureDeviceInput!
  private var setupResult: SessionSetupResult = .success
  private let session = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "com.quanshousio.capturesession")
  private var isSessionRunning: Bool = false
  private var previewView: CameraPreviewView!

  #if !os(macOS)
  private var windowOrientation: UIInterfaceOrientation {
    view.window?.windowScene?.interfaceOrientation ?? .unknown
  }
  #endif

  private var qrCodeFrameView: UXView!

  weak var delegate: TicketScannerView.Coordinator?
  var metadataObjectTypes: [AVMetadataObject.ObjectType] = []

  #if os(macOS)
  override func loadView() {
    view = UXView()
  }
  #endif

  override func viewDidLoad() {
    super.viewDidLoad()
    #if !os(macOS)
    view.backgroundColor = .black
    #endif

    previewView = CameraPreviewView()
    previewView.session = session
    previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
    view.addSubview(previewView)
    previewView.translatesAutoresizingMaskIntoConstraints = false
    previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    qrCodeFrameView = UXView()

    #if !os(macOS)
    qrCodeFrameView.layer.borderWidth = 2
    qrCodeFrameView.layer.borderColor = UIColor.cdsl.cgColor
    qrCodeFrameView.clipsToBounds = true
    view.addSubview(qrCodeFrameView)
    view.bringSubviewToFront(qrCodeFrameView)
    #else
    qrCodeFrameView.layer?.borderWidth = 2
    qrCodeFrameView.layer?.borderColor = NSColor.cdsl.cgColor
    view.addSubview(qrCodeFrameView)
    #endif

    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      break
    case .notDetermined:
      /*
       The user has not yet been presented with the option to grant video access.
       Suspend the session queue to delay session setup until the access request has completed.

       Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput
       for audio during session setup.
       */
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        guard let self = self else { return }
        if !granted {
          self.setupResult = .notAuthorized
        }
        self.sessionQueue.resume()
      }
    default:
      setupResult = .notAuthorized
    }

    /*
     Setup the capture session.
     In general, it's not safe to mutate an AVCaptureSession or any of its inputs, outputs,
     or connections from multiple threads at the same time.

     Don't perform these tasks on the main queue because AVCaptureSession.startRunning() is a
     blocking call, which can take a long time. Dispatch session setup to the sessionQueue, so that
     the main queue isn't blocked, which keeps the UI responsive.
     */
    sessionQueue.async {
      self.configureSession()
    }
  }

  #if !os(macOS)
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    willAppear()
  }
  #else
  override func viewWillAppear() {
    super.viewWillAppear()
    willAppear()
  }
  #endif

  private func willAppear() {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      switch self.setupResult {
      case .success:
        // Only setup observers, add focus tap and start the session if setup succeeded.
        self.addObservers()
        DispatchQueue.main.async {
          #if !os(macOS)
          let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.focusAndExposeTap)
          )
          #else
          let tapGestureRecognizer = NSClickGestureRecognizer(
            target: self,
            action: #selector(self.focusAndExposeTap)
          )
          #endif
          self.view.addGestureRecognizer(tapGestureRecognizer)
        }
        self.session.startRunning()
        self.isSessionRunning = self.session.isRunning

      case .notAuthorized:
        DispatchQueue.main.async {
          let usageDescription = Bundle.main
            .object(forInfoDictionaryKey: "NSCameraUsageDescription") as! String
          #if !os(macOS)
          let alert = UIAlertController(
            title: usageDescription,
            message: L10n.askChangePermissionSettings,
            preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: L10n.changeSettings, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
          let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel)
          alert.addAction(okAction)
          alert.addAction(cancelAction)
          self.present(alert, animated: true)
          #else
          let alert = NSAlert()
          alert.messageText = usageDescription
          alert.informativeText = L10n.askChangePermissionSettings
          alert.addButton(withTitle: "OK")
          alert.runModal()
          #endif
        }

      case .configurationFailed:
        DispatchQueue.main.async {
          #if !os(macOS)
          let alert = UIAlertController(
            title: L10n.error,
            message: L10n.Camera.failedToInitialize,
            preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: "OK", style: .default)
          alert.addAction(okAction)
          self.present(alert, animated: true)
          #else
          let alert = NSAlert()
          alert.messageText = L10n.error
          alert.informativeText = L10n.Camera.failedToInitialize
          alert.addButton(withTitle: "OK")
          alert.runModal()
          #endif
        }
      }
    }
  }

  #if !os(macOS)
  override func viewWillDisappear(_ animated: Bool) {
    willDisappear()
    super.viewWillDisappear(animated)
  }
  #else
  override func viewWillDisappear() {
    willDisappear()
    super.viewWillDisappear()
  }
  #endif

  private func willDisappear() {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      if self.setupResult == .success {
        self.session.stopRunning()
        self.isSessionRunning = self.session.isRunning
        NotificationCenter.default.removeObserver(self)
      }
    }
  }

  #if !os(macOS)
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)
    if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
      let deviceOrientation = UIDevice.current.orientation
      guard let newVideoOrientation =
        AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
        deviceOrientation.isPortrait || deviceOrientation.isLandscape
      else {
        return
      }
      videoPreviewLayerConnection.videoOrientation = newVideoOrientation
    }
  }
  #endif

  private func configureSession() {
    if setupResult != .success {
      return
    }

    session.beginConfiguration()

    /*
     Do not create an AVCaptureMovieFileOutput when setting up the session because
     Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
     */
    session.sessionPreset = .photo

    // Add video input.
    do {
      var defaultVideoDevice: AVCaptureDevice?

      #if !os(macOS)
      // Choose the back dual camera, if available, otherwise default to a wide angle camera.
      if let dualCameraDevice = AVCaptureDevice.default(
        .builtInDualCamera,
        for: .video,
        position: .back
      ) {
        defaultVideoDevice = dualCameraDevice
      } else if let backCameraDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: .back
      ) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        defaultVideoDevice = backCameraDevice
      } else if let frontCameraDevice = AVCaptureDevice
        .default(.builtInWideAngleCamera, for: .video, position: .front)
      {
        // If the rear wide angle camera isn't available, default to the front wide angle camera.
        defaultVideoDevice = frontCameraDevice
      }
      #else
      if let backCameraDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: .back
      ) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        defaultVideoDevice = backCameraDevice
      } else if let frontCameraDevice = AVCaptureDevice
        .default(.builtInWideAngleCamera, for: .video, position: .front)
      {
        // If the rear wide angle camera isn't available, default to the front wide angle camera.
        defaultVideoDevice = frontCameraDevice
      }
      #endif

      guard let videoDevice = defaultVideoDevice else {
        print("[Camera] Default video device is unavailable")
        setupResult = .configurationFailed
        session.commitConfiguration()
        return
      }

      let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

      if session.canAddInput(videoDeviceInput) {
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput

        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          /*
           Dispatch video streaming to the main queue because
           AVCaptureVideopreviewView.videoPreviewLayer is the backing layer for PreviewView.
           You can manipulate UIView only on the main thread.
           Note: As an exception to the above rule, it's not necessary to serialize video
           orientation changes on the AVCaptureVideopreviewView.videoPreviewLayer’s connection with
           other session manipulation.

           Use the window scene's orientation as the initial video orientation. Subsequent
           orientation changes are handled by CameraViewController.viewWillTransition(to:with:).
           */
          var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
          #if !os(macOS)
          if self.windowOrientation != .unknown {
            if let videoOrientation =
              AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation)
            {
              initialVideoOrientation = videoOrientation
            }
          }
          #endif
          self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
        }
      } else {
        print("[Camera] Couldn't add video device input to the session")
        setupResult = .configurationFailed
        session.commitConfiguration()
        return
      }
    } catch {
      print("[Camera] Couldn't create video device input: \(error)")
      setupResult = .configurationFailed
      session.commitConfiguration()
      return
    }

    // Add the metadata output.
    #if !os(macOS)
    let captureMetadataOutput = AVCaptureMetadataOutput()
    if session.canAddOutput(captureMetadataOutput) {
      session.addOutput(captureMetadataOutput)

      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = metadataObjectTypes
    } else {
      print("[Camera] Couldn't add capture metadata output to the session")
      setupResult = .configurationFailed
      session.commitConfiguration()
      return
    }
    #endif

    session.commitConfiguration()
  }

//  func resumeInterruptedSession() {
//    sessionQueue.async { [self] in
//      /*
//       The session might fail to start running, for example, if a phone or FaceTime call is still
//       using audio or video. This failure is communicated by the session posting a runtime error
//       notification. To avoid repeatedly failing to start the session, only try to restart the
//       session in the error handler if you aren't trying to resume the session.
//       */
//      session.startRunning()
//      isSessionRunning = session.isRunning
//
//      if !session.isRunning {
//        DispatchQueue.main.async {
//          let title = L10n.error
//          let message = L10n.Camera.failedToResume
//          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//          let cancelAction = UIAlertAction(title: "OK", style: .default)
//          alert.addAction(cancelAction)
//          present(alert, animated: true)
//        }
//      }
//    }
//  }

  func enableCaptureConnection() {
    previewView.videoPreviewLayer.connection?.isEnabled = true
  }

  func disableCaptureConnection() {
    previewView.videoPreviewLayer.connection?.isEnabled = false
  }

  private func focus(
    with focusMode: AVCaptureDevice.FocusMode,
    exposureMode: AVCaptureDevice.ExposureMode,
    at devicePoint: CGPoint,
    monitorSubjectAreaChange: Bool
  ) {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      let device = self.videoDeviceInput.device
      do {
        try device.lockForConfiguration()

        if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(focusMode) {
          device.focusPointOfInterest = devicePoint
          device.focusMode = focusMode
        }

        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(exposureMode) {
          device.exposurePointOfInterest = devicePoint
          device.exposureMode = exposureMode
        }
        #if !os(macOS)
        device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
        #endif
        device.unlockForConfiguration()
      } catch {
        print("[Camera] Failed to lock device for configuration: \(error)")
      }
    }
  }

  private func addObservers() {
    #if !os(macOS)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(subjectAreaDidChange),
      name: .AVCaptureDeviceSubjectAreaDidChange,
      object: videoDeviceInput.device
    )
    #endif

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionRuntimeError),
      name: .AVCaptureSessionRuntimeError,
      object: session
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionWasInterrupted),
      name: .AVCaptureSessionWasInterrupted,
      object: session
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionInterruptionEnded),
      name: .AVCaptureSessionInterruptionEnded,
      object: session
    )
  }

  @objc private func subjectAreaDidChange(notification: Notification) {
    let devicePoint = CGPoint(x: 0.5, y: 0.5)
    focus(
      with: .continuousAutoFocus,
      exposureMode: .continuousAutoExposure,
      at: devicePoint,
      monitorSubjectAreaChange: false
    )
  }

  @objc private func sessionRuntimeError(notification: Notification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
    print("[Camera] Capture session runtime error: \(error)")
    #if !os(macOS)
    if error.code == .mediaServicesWereReset {
      sessionQueue.async { [weak self] in
        guard let self = self else { return }
        if self.isSessionRunning {
          self.session.startRunning()
          self.isSessionRunning = self.session.isRunning
        }
      }
    }
    #else
    if error.code == .mediaDiscontinuity {
      sessionQueue.async { [weak self] in
        guard let self = self else { return }
        if self.isSessionRunning {
          self.session.startRunning()
          self.isSessionRunning = self.session.isRunning
        }
      }
    }
    #endif
  }

  @objc private func sessionWasInterrupted(notification: Notification) {
    /*
     In some scenarios you want to enable the user to resume the session.
     For example, if music playback is initiated from Control Center while using AVCam, then the user can let AVCam
     resume the session running, which will stop music playback.
     Note that stopping music playback in Control Center will not automatically resume the session.
     Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
     */
    #if !os(macOS)
    if let userInfoValue = notification
      .userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
      let reasonIntegerValue = userInfoValue.integerValue,
      let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue)
    {
      print("[Camera] Capture session was interrupted with reason: \(reason)")
    }
    #endif
  }

  @objc private func sessionInterruptionEnded(notification: Notification) {
    print("[Camera] Capture session interruption ended")
  }

  #if !os(macOS)
  @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
    let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(
      fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)
    )
    focus(
      with: .autoFocus,
      exposureMode: .autoExpose,
      at: devicePoint,
      monitorSubjectAreaChange: true
    )
  }
  #else
  @objc private func focusAndExposeTap(_ gestureRecognizer: NSClickGestureRecognizer) {
    let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(
      fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)
    )
    focus(
      with: .autoFocus,
      exposureMode: .autoExpose,
      at: devicePoint,
      monitorSubjectAreaChange: true
    )
  }
  #endif
}

#if !os(macOS)
extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(
    _ output: AVCaptureMetadataOutput,
    didOutput metadataObjects: [AVMetadataObject],
    from connection: AVCaptureConnection
  ) {
    // not found
    guard let metadataObject = metadataObjects.first else {
      qrCodeFrameView.frame = .zero
      return
    }

    guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
          metadataObjectTypes.contains(readableObject.type)
    else { return }

    if let transformedObject = previewView.videoPreviewLayer
      .transformedMetadataObject(for: metadataObject)
    {
      qrCodeFrameView.frame = transformedObject.bounds
    }

    if let stringValue = readableObject.stringValue {
      delegate?.cameraDidFindStringFromMetadataObject(self, string: stringValue)
    }
  }
}
#endif
