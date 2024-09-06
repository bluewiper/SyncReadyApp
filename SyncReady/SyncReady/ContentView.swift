//
//  ContentView.swift
//  SyncReady
//
//  Created by 단예진 on 8/31/24.
//

// ShareViewController Realm에 저장된 데이터 조회로 시작해야 되는 거 아닌가..? 이미 거기서 add를 했는데..
// 마쟈용~ 이제 앱에서 조회 가능! 내용 수정할 수 있어야 함!!


// 수정 가능한 코드
import SwiftUI
import RealmSwift

// Realm에서 저장된 Event 데이터를 가져와 ContentView에서 표시 및 수정 가능하게 함
struct ContentView: View {
    @State private var latestEvent: Event?  // 최근 저장된 이벤트를 저장할 상태
    @State private var newTitle: String = ""
    @State private var newDate: String = ""
    @State private var newTime: String = ""
    @State private var newLocation: String = ""
    @State private var newDescription: String = ""

    var body: some View {
        VStack {
            if let event = latestEvent {
                // 수정 가능한 텍스트 필드
                VStack {
                    TextField("타이틀", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    TextField("날짜", text: $newDate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    TextField("시간", text: $newTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    TextField("위치", text: $newLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    TextEditor(text: $newDescription)
                        .frame(height: 100)
                        .border(Color.gray)
                        .padding(.bottom, 8)
                }

                // 수정 저장 버튼
                Button(action: {
                    updateEvent()
                }) {
                    Text("수정 저장")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            } else {
                Text("저장된 일정이 없습니다.")
            }
        }
        .padding()
        .onAppear(perform: fetchLatestEvent)  // 뷰가 나타날 때 가장 최근 이벤트 불러오기
    }

    // 최근 저장된 Event 데이터를 불러오는 함수
    func fetchLatestEvent() {
        let realm = try! Realm(configuration: realmConfig()) // 수정된 Realm config 사용
        if let event = realm.objects(Event.self).sorted(byKeyPath: "date", ascending: false).first {
            latestEvent = event
            newTitle = event.title
            newDate = event.date
            newTime = event.time
            newLocation = event.location ?? ""  // 옵셔널 언래핑, 기본값 빈 문자열
            newDescription = event.eventDescription ?? ""  // 옵셔널 언래핑, 기본값 빈 문자열
        }
    }

    // Realm에서 데이터를 수정하는 함수
    func updateEvent() {
        guard let event = latestEvent else { return }

        let realm = try! Realm(configuration: realmConfig())
        try! realm.write {
            event.title = newTitle
            event.date = newDate
            event.time = newTime
            event.location = newLocation
            event.eventDescription = newDescription
        }

        // 데이터 업데이트 후에 다시 불러오기
        fetchLatestEvent()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
