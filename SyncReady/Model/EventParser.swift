//
//  EventParser.swift
//  SyncReady
//
//  Created by 단예진 on 9/6/24.
//

import Foundation

class EventParser {
    func parse(jsonString: String) -> Event? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                let title = json["title"] ?? "제목 없음"
                let date = json["date"] ?? "날짜 없음"
                let time = json["time"] ?? "시간 없음"
                let location = json["location"] ?? "위치 없음"
                let description = json["description"] ?? "설명 없음"
                
                return Event(title: title, date: date, time: time, location: location, eventDescription: description)
            }
        } catch {
            print("JSON 파싱 중 오류 발생: \(error.localizedDescription)")
        }
        
        return nil
    }
}
