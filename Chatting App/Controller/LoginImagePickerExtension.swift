//
//  LoginImagePickerExtension.swift
//  Chatting App
//
//  Created by Raju on 7/27/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

extension LoginController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imageViewAction() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            imageView.image = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            imageView.image = originalImage as? UIImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
