//
//  ShareViewController.swift
//  Share
//
//  Created by 단예진 on 8/31/24.
//

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        print("ShareViewController loaded")
        
        let customView = ShareCustomView(frame: self.view.bounds)
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        loadImage { image in
            print("Image received in loadImage: \(image != nil)")
            // UI 업데이트를 메인 스레드에서 수행
            DispatchQueue.main.async {
                customView.shareImageView.image = image  // 이미지 설정
            }
        }
        
        print("ShareViewController finished setting up views")
    }
    
    private func loadImage(completion: @escaping (UIImage?) -> Void) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            print("No attachments found")
            completion(nil)
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
            print("Found public.jpeg conforming item")
            itemProvider.loadItem(forTypeIdentifier: UTType.jpeg.identifier, options: nil) { (imageData, error) in
                if let error = error {
                    print("Error loading item: \(error)")
                    completion(nil)
                    return
                }
                
                if let url = imageData as? URL {
                    print("Item is URL: \(url)")
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            print("Image successfully loaded from URL")
                            completion(image)
                        } else {
                            print("Failed to create UIImage from data")
                            completion(nil)
                        }
                    } catch {
                        print("Error loading data from URL: \(error)")
                        completion(nil)
                    }
                } else if let image = imageData as? UIImage {
                    print("Item is UIImage")
                    completion(image)
                } else {
                    print("Failed to load image: Item is not URL or UIImage")
                    completion(nil)
                }
            }
        } else {
            print("No conforming image type found")
            completion(nil)
        }
    }
    
    private func handleShareAction() {
        print("Share action triggered")
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
