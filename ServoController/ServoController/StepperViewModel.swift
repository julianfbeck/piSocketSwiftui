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
    @Published var isConnected = false
    @Published var isRunning = false

    @Published var isStopped = false

    init () {
        self.connect()
    }
    
    public func step(direction: Direction, steps: Int) {
        switch direction {
        case .left:
            socket.emit("step",  -1 * steps)
        case .right:
            socket.emit("step", 1 * steps)
            
        }
        
    }
    
    public func setSpeed(speed: Double) {
        socket.emit("speed", speed)
    }
    
    public func resetPosition() {
        socket.emit("resetPosition", 0)
    }
    
    public func stop() {
        socket.emit("stop", 0)
    }
    
    public func go() {
        socket.emit("go", 0)
    }
    
    private func connect() {
        self.manager = SocketManager(socketURL: URL(string: "http://192.168.178.94:5000/")!, config: [.log(false), .compress, .forceWebsockets(false)])
        
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
        
        socket.on("stop") { data, ack in
            print(data)
            if let stop = data[0] as? Int {
                self.isStopped = stop == 0 ? false : true
            }
        }

        socket.on(clientEvent: .connect) {  _, _ in
            print("socket connected")
            self.socket.emit("pull", 0)
            self.isConnected = true
        }
        
        socket.on(clientEvent: .disconnect) {  _, _ in
            print("socket disconnected")
            self.isConnected = false

        }
        
        socket.on(clientEvent: .error) {   error, _ in
            print(error)
            self.isConnected = false

        }
    }
}

public enum Direction:String, CaseIterable {
    case left
    case right
}



