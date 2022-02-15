//
//  ImageDownloader.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import UIKit
import SwiftUI

struct CachedImages {
    /*
     * In this first stage all images will have the same cost
     * There is no use of countLimit and totalCostLimit
     */
    static var images = NSCache<NSString, UIImage>()
    
    static func add(image: UIImage, forURL url: String) {
        images.setObject(image, forKey: url as NSString, cost: 1)
    }
    
    static func get(url: String) -> UIImage? {
        return images.object(forKey: url as NSString)
    }
    
    static func empty() {
        images.removeAllObjects()
    }
}

final class ImageDownloader: ObservableObject {
    @Published var image: UIImage?
    private var sessionTask: URLSessionDataTask?
    
    init(imageURL: String?, addToCache: Bool = false) {
        guard let imageURL = imageURL,
            let url = URL(string: imageURL)  else { return }
        
        if let image = CachedImages.get(url: imageURL) {
            self.image = image
        } else {
            sessionTask = URLSession.shared.dataTask(with: URLRequest(url:url), completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data,
                    let image = UIImage(data: data) {
                    if addToCache {
                        CachedImages.add(image: image, forURL: imageURL)
                    }
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            })
            sessionTask?.resume()
        }
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageDownloader
    
    var size: CGFloat

    init(withURL url: String?, size: CGFloat = 50.0) {
        self.imageLoader = ImageDownloader(imageURL: url, addToCache: true)
        self.size = size
    }

    var body: some View {
        Image(uiImage: imageLoader.image != nil ? imageLoader.image! : UIImage())
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

class ImagePickerCordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    let completion: () -> Void

    
    init(isShown : Binding<Bool>, image: Binding<UIImage?>,  completion: @escaping () -> Void) {
        _isShown = isShown
        _image   = image
        self.completion = completion
    }
    
    //Selected Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        completion()
        isShown = false
    }
    
    //Image selection got cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion()
        isShown = false
    }
}

struct ImagePicker : UIViewControllerRepresentable {
    var withCameraOn: Bool
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    let completion: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = withCameraOn ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> ImagePickerCordinator {
        return ImagePickerCordinator(isShown: $isShown, image: $image, completion: completion)
    }
}

struct PhotoCaptureView: View {
    var withCameraOn: Bool = false
    @Binding var showImagePicker: Bool
    @Binding var image: UIImage?
    let completion: () -> Void

    var body: some View {
        ImagePicker(withCameraOn: withCameraOn, isShown: $showImagePicker, image: $image, completion: completion)
    }
}

struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false), image: .constant(UIImage()), completion: {})
    }
}
