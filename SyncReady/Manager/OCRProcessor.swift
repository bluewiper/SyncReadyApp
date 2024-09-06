//
//  OCRProcessor.swift
//  SyncReady
//
//  Created by 단예진 on 9/6/24.
//


// OCR 테스트 때 한국어 출력까지 잘 된 코드
import UIKit
import MLKitTextRecognitionKorean
import MLKitVision

class OCRProcessor {

    func processImageForTextRecognition(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        // VisionImage 객체 생성
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        // TextRecognizer 인스턴스 생성 (한국어 인식에 최적화)
        let textRecognizer = TextRecognizer.textRecognizer(options: KoreanTextRecognizerOptions())

        // 텍스트 인식 수행
        textRecognizer.process(visionImage) { result, error in
            if let error = error {
                print("텍스트 인식 중 오류 발생: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let result = result else {
                print("텍스트 인식 결과 없음")
                completion(nil, nil)
                return
            }

            // 인식된 텍스트 블록들을 하나의 문자열로 결합
            let recognizedText = result.text
            completion(recognizedText, nil)
        }
    }
}

