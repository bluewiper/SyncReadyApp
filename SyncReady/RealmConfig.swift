//
//  RealmConfig.swift
//  SyncReady
//
//  Created by 단예진 on 9/6/24.
//

// 앱과 Share Extension이 같은 Realm 파일을 공유하도록 Realm의 경로를 App Group 디렉토리로 설정

import RealmSwift

func realmConfig() -> Realm.Configuration {
    
    // 앱그룹 경로 설정
    guard let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yejindan.SyncReady")?
        .appendingPathComponent("default.realm") else {
            fatalError("App Group 경로를 찾을 수 없습니다.")
        }
    
    let config = Realm.Configuration(fileURL: fileURL)
    return config
}

let realm = try! Realm(configuration: realmConfig())
