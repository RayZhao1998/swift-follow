//
//  App.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/17.
//

import SwiftUI
import FollowAPI

@main
struct swift_followApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
