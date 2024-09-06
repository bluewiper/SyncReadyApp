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
import RealmSwift

class ShareViewController: UIViewController {
    
    let ocrProcessor = OCRProcessor()
    let openAIClient = OpenAIClient()
    
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
        
        // 일정 생성 버튼에 액션 추가
        customView.generateScheduleButton.addTarget(self, action: #selector(handleShareAction), for: .touchUpInside)
        
        loadImage { image in
            print("Image received in loadImage: \(image != nil)")
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
            itemProvider.loadItem(forTypeIdentifier: UTType.jpeg.identifier, options: nil) { (imageData, error) in
                if let url = imageData as? URL {
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
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
    
    @objc private func handleShareAction() {
        guard let image = (view.subviews.first as? ShareCustomView)?.shareImageView.image else {
            print("OCR 처리할 이미지가 없습니다.")
            return
        }

        processImage(image) { [weak self] event in
            guard let event = event else {
                print("Event 생성 실패")
                return
            }

            self?.saveEventToRealm(event)
            self?.printSavedEvents()
        }
    }

    
    private func processImage(_ image: UIImage, completion: @escaping (Event?) -> Void) {
        // 1. OCR로 텍스트 인식
        ocrProcessor.processImageForTextRecognition(image: image) { [weak self] recognizedText, error in
            if let error = error {
                print("텍스트 인식 중 오류 발생: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let text = recognizedText else {
                print("인식된 텍스트 없음")
                completion(nil)
                return
            }
            
            print("인식된 전체 텍스트: \(text)")
            
            // 2. OpenAI로 일정 정보 분석
            self?.openAIClient.callOpenAIWithRetry(text: text, retryCount: 3, delay: 10.0) { result in
                guard let result = result else {
                    print("OpenAI로부터 일정 정보를 가져오지 못했습니다.")
                    completion(nil)
                    return
                }
                
                print("OpenAI 분석 결과: \(result)")
                
                // 3. JSON 파싱 및 Event 생성
                let eventParser = EventParser()
                if let event = eventParser.parse(jsonString: result) {
                    completion(event)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // Realm에 Event 객체 저장
    private func saveEventToRealm(_ event: Event) {
        let realm = try! Realm(configuration: realmConfig()) // 수정된 Realm config 사용
        
        try! realm.write {
            realm.add(event)
            print("Event 저장 성공: \(event.title)")
        }
        
    }
    
    // 저장된 모든 Event 객체를 출력
    private func printSavedEvents() {
        let realm = try! Realm() // Realm 인스턴스 생성
        let events = realm.objects(Event.self) // Realm에서 모든 Event 객체 가져오기
        
        print("저장된 Events:")
        for event in events {
            printEvent(event)
        }
    }
    
    private func printEvent(_ event: Event) {
        print("타이틀: \(event.title)")
        print("날짜: \(event.date)")
        print("시간: \(event.time)")
        print("위치: \(event.location)")
        print("추가: \(event.eventDescription)")
    }
}

