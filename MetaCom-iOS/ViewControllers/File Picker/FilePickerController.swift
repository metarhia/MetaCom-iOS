//
//  FilePickerController.swift
//  MetaCom-iOS
//
//  Created by iKing on 12.06.17.
//  Copyright © 2017 Metarhia. All rights reserved.
//

import UIKit

private extension UIImagePickerController {
	
	convenience init(sourceType type: UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
		self.init()
		self.sourceType = type
		self.delegate = delegate
	}
}

class FilePickerController: UIViewController {
	
	weak var delegate: FilePickerControllerDelegate?
	
	override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	private func setup() {
		self.modalPresentationStyle = .overCurrentContext
	}
	
	fileprivate func dismiss() {
		self.presentingViewController?.dismiss(animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		present(createAlert(), animated: true)
	}
	
	private func createAlert() -> UIAlertController {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let cancelHandler: (UIAlertAction) -> () = { _ in
			self.dismiss()
		}
		
		let media = UIAlertAction(title: "Photo or Video", style: .default) { _ in
			
			let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { _ in
				let imagePicker = UIImagePickerController(sourceType: .photoLibrary, delegate: self)
				self.present(imagePicker, animated: true)
			}
			
			let camera = UIAlertAction(title: "Camera", style: .default) { _ in
				let imagePicker = UIImagePickerController(sourceType: .camera, delegate: self)
				self.present(imagePicker, animated: true)
			}
			
			photoLibrary.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
			camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
			
			alert.addAction(photoLibrary)
			alert.addAction(camera)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
			
			self.present(alert, animated: true)
		}
		
		let iCloudDrive = UIAlertAction(title: "iCloud Drive", style: .default) { _ in
			let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
			documentPickerController.delegate = self
			self.present(documentPickerController, animated: true)
		}
		
		alert.addAction(media)
		alert.addAction(iCloudDrive)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
		
		return alert
	}
	
}

extension FilePickerController: UIDocumentPickerDelegate {
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		delegate?.filePicker(self, didPickFileAt: url)
		
		self.dismiss()
	}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		self.dismiss()
	}
}

extension FilePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		picker.dismiss(animated: true, completion: nil)
		
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			return
		}
		
		guard let data = UIImagePNGRepresentation(image) else {
			return
		}
		
		delegate?.filePicker(self, didPickData: data)
		
		self.dismiss()
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss()
	}
}