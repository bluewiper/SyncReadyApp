//
//  OpenAIClient.swift
//  SyncReady
//
//  Created by 단예진 on 9/6/24.
//

import Foundation

class OpenAIClient {
    func analyzeTextWithGPT(text: String, completion: @escaping (String?) -> Void) {
        let apiKey = "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"  // 여기에 실제 API 키를 입력해야 합니다.
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Please extract the event details from the following text and provide them in this JSON format, using only the Korean language. If any part of the text is in English, please translate it into Korean:

        {
            "title": "이벤트 제목",
            "date": "YYYY-MM-DD",
            "time": "HH:MM AM/PM",
            "location": "이벤트 위치",
            "description": "추가 설명"
        }

        Important guidelines:
        1. **Title**: Extract the main event title or subject from the text.
        2. **Date**: Look for the specific date mentioned in the context of when the event will take place (not the date the message was sent). If the text includes relative terms like "금일" (today), "내일" (tomorrow), or "모레" (the day after tomorrow), replace them with the actual date based on when the message was written.
        3. **Time**: Extract the event's scheduled time, not the time the message was written or sent.
        4. **Location**: If a physical or virtual location is mentioned (e.g., an address, Zoom link), include it in the location field.
        5. **Description**: Include any other relevant details about the event that do not fit in the above fields.

        Now, please extract the event information from this text in Korean: "\(text)"
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "Ignore the time the sender sent, make sure you inform the plans inside the text."],
            ["role": "user", "content": prompt]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 200,  // 조금 더 여유롭게 설정
            "temperature": 0.3
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 429 {
                    print("Non-200 response received: \(httpResponse.statusCode) - Rate limit exceeded")
                    completion(nil)
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // 응답 데이터를 출력하여 확인합니다.
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            // 응답 데이터를 JSON으로 파싱합니다.
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    print("Failed to parse GPT response - unexpected structure")
                    completion(nil)
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // 재시도 로직 포함
    func callOpenAIWithRetry(text: String, retryCount: Int = 3, delay: TimeInterval = 10.0, completion: @escaping (String?) -> Void) {
        analyzeTextWithGPT(text: text) { result in
            if result == nil && retryCount > 0 {
                print("Retrying... \(retryCount) attempts left")
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    self.callOpenAIWithRetry(text: text, retryCount: retryCount - 1, delay: delay * 2, completion: completion)
                }
            } else {
                completion(result)
            }
        }
    }
}



