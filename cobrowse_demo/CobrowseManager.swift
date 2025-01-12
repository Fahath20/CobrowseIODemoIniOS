//
//  CobrowseManager.swift
//  cobrowse_demo
//
//  Created by Fahath Rajak on 1/12/25.
//

import CobrowseIO

class CobrowseManager: NSObject, ObservableObject {
    
    let cobrowseIO = CobrowseIO.instance()
    
    private var sessionActive: Bool {
        cobrowseIO.currentSession()?.state() == "active"
    }
    
    @Published var cobrowseSession = CBIOSession()
    @Published var sessionRequested = false
    @Published var isSessionActive = false

    override init() {
        super.init()
    }
    
    // Initialize Cobrowse session So An agent can request to use the app
    func initSession(userEmail: String, capabilities: [String]) {
        cobrowseIO.license = "WSjcu3bYLoczwg"
        cobrowseIO.customData = [
//            kCBIOUserIdKey: "<your_user_id>" as NSObject,
//            kCBIOUserNameKey: "<your_user_name>" as NSObject,
            kCBIOUserEmailKey: userEmail as NSObject,
//            kCBIODeviceIdKey: "<your_device_id>" as NSObject,
            kCBIODeviceNameKey: UIDevice.current.name as NSObject
        ]
        cobrowseIO.capabilities = capabilities
        cobrowseIO.delegate = self
        cobrowseIO.start()
    }
    
    // Generate 6 digit code So An agent can use this code to access the application
    private func createSession(userEmail: String, capabilities: [String], completionHandler: @escaping (String?) -> Void) {
        self.initSession(userEmail: userEmail, capabilities: capabilities)
        //CobrowseIO.instance().registration = false
        CobrowseIO.instance().createSession { error, session in
            if error != nil {
                completionHandler(nil)
            } else if let session {
                print(session.code() ?? "No Session code available")
                completionHandler(session.code())
            } else {
                completionHandler(nil)
            }
        }
    }
    
    // Check for an active session and end it to restart the connection to get 6 digit code to co browse with agent
    func establishSessionFromUser(userEmail: String, capabilities: [String], completionHandler: @escaping (String?) -> Void) {
        if isSessionActive {
            endSession { result in
                if result == "ended" {
                    self.createSession(userEmail: userEmail, capabilities: capabilities, completionHandler: completionHandler)
                }
            }
        } else {
            self.createSession(userEmail: userEmail, capabilities: capabilities, completionHandler: completionHandler)
        }
    }
    
    // Activate session manually through custom UI
    func activateSession() {
        cobrowseIO.currentSession()?.activate()
    }
    
    // End current session
    func endSession(completionHandler: @escaping (String) -> Void) {
        cobrowseIO.currentSession()?.end({ error, session in
            if let error {
                print("Error occured", error)
                completionHandler("error")
            } else if let session {
                print(session.state())
                completionHandler(session.state())
            } else {
                print("Unknown Error Occured")
                completionHandler("Unknown Error Occured")
            }
        })
    }
}

extension CobrowseManager: CobrowseIODelegate {
    
    // Called everytime when session state changed
    func cobrowseSessionDidUpdate(_ session: CBIOSession) {
        self.cobrowseSession = session
        self.isSessionActive = sessionActive
    }
    
    // Called everytime when session ended
    func cobrowseSessionDidEnd(_ session: CBIOSession) {
        self.cobrowseSession = session
        self.isSessionActive = sessionActive
    }
    
    // Called everytime when session started
    func cobrowseSessionDidLoad(_ session: CBIOSession) {
        self.cobrowseSession = session
        self.isSessionActive = sessionActive
    }
    
    // Called everytime when agent requested to connect with application
    // Update session so an alert will be shown to user
    func cobrowseHandleSessionRequest(_ session: CBIOSession) {
        self.sessionRequested = true
        self.cobrowseSession = session
        self.isSessionActive = sessionActive
    }
}


