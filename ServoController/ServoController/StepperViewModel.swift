//
//  ServoViewModel.swift
//  ServoController
//
//  Created by Julian Beck on 18.05.20.
//  Copyright © 2020 Julian Beck. All rights reserved.
//

import Foundation

import Foundation
import Combine
import SocketIO
final class StepperViewModel: ObservableObject {
    var socket:SocketIOClient!
    var manager: SocketManager!
    
    @Published var totalSteps = 0
    @Published var totalSpeed = 0.0 
    

    init () {
        self.connect()
    }
    
    public func step(direction: Direction) {
        switch direction {
        case .left:
            socket.emit("step", -1)
        case .right:
            socket.emit("step", +1)
            
        }
        
    }
    
    public func setSpeed(speed: Double) {
        socket.emit("speed", speed)
    }
    
    public func resetPosition() {
        socket.emit("resetPosition", 0)
    }
    
    private func connect() {
        self.manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:5000/")!, config: [.log(true), .compress, .forceWebsockets(false)])
        
        self.socket = manager.socket(forNamespace: "/test")
        
        addHandlers()
        socket.connect()
    }
    
    private  func addHandlers() {
        socket.on("totalPosition") { data, ack in
            if let steps = data[0] as? Int {
                self.totalSteps = steps
            }
        }
        
        socket.on("totalSpeed") { data, ack in
            print("totalSpeed")
            if let speed = data[0] as? Double {
                self.totalSpeed = speed
            }
        }

        socket.on(clientEvent: .connect) {  _, _ in
            print("socket connected")
            self.socket.emit("pull", 0)
        }
        
        socket.on(clientEvent: .disconnect) {  _, _ in
            print("socket disconnected")
            
        }
    }
}

public enum Direction {
    case left
    case right
}



