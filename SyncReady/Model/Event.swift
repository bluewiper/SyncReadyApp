//
//  Event.swift
//  SyncReady
//
//  Created by 단예진 on 9/6/24.
//

import RealmSwift

class Event: Object {
    @Persisted var title: String = ""
    @Persisted var date: String = ""
    @Persisted var time: String = ""
    @Persisted var location: String? = ""
    @Persisted var eventDescription: String? = "" //'description'은 Swift의 예약어이므로 변수명 변경
    
    convenience init(title: String, date: String, time: String, location: String?, eventDescription: String?) {
        self.init()
        self.title = title
        self.date = date
        self.time = time
        self.location = location
        self.eventDescription = eventDescription
    }
}
