//
//  cobrowse_demoApp.swift
//  cobrowse_demo
//
//  Created by Fahath Rajak on 1/10/25.
//

import SwiftUI
import CobrowseIO

@main
struct cobrowse_demoApp: App {
    
    init() {
        CobrowseIO.instance().license = "WSjcu3bYLoczwg"
        CobrowseIO.instance().customData = [
//            kCBIOUserIdKey: "<your_user_id>" as NSObject,
//            kCBIOUserNameKey: "<your_user_name>" as NSObject,
            kCBIOUserEmailKey: "fahathr@gmail.com" as NSObject,
            //kCBIODeviceIdKey: "<your_device_id>" as NSObject,
            kCBIODeviceNameKey: "iPhone 15 Pro" as NSObject
        ]
        
        CobrowseIO.instance().capabilities = ["laser"]
        CobrowseIO.instance().start()
        CobrowseIO.instance().registration = false
        CobrowseIO.instance().createSession { error, session in
            if let error {
                print("Error occured", error)
            } else if let session {
                print(session.code() ?? "No Session code available")
            } else {
                print("Error Occured")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
