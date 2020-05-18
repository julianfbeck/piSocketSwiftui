//
//  ContentView.swift
//  ServoController
//
//  Created by Julian Beck on 18.05.20.
//  Copyright © 2020 Julian Beck. All rights reserved.
//

import SwiftUI
import SocketIO
struct ContentView: View {
    @ObservedObject var model = StepperViewModel()

 
    
    
    
    
    init() {
        
    }
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        VStack {
                            Text("\(self.model.totalSteps)").font(.title).bold()
                            
                            Spacer()
                            Text("Total Steps").font(.caption).bold()
                        }
                        Spacer()
                        VStack {                            Text("180°").font(.title).bold()
                            Spacer()
                            Text("Position").font(.caption).bold()
                            
                        }
                    }
                }.listRowBackground(Color("systemBackground"))
                Section {
                    Stepper(onIncrement: {
                        self.model.step(direction: .right)
                    }, onDecrement: {
                        self.model.step(direction: .left)
                    }) {
                        Text("Step")
                    }
                }
                
                Section {
                    HStack {
                        Text("Speed").padding(.trailing)
                        Slider(value: Binding(
                            get: {
                                self.model.totalSpeed
                            },
                            set: {(newValue) in
                                self.model.setSpeed(speed: newValue)
                            }
                        ), in: 0...100, step: 0.1)
                    }
                }
                Button(action: {
                    self.model.resetPosition()
                }) {
                    Text("Reset Position")
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Stepper")
        }
    }
    
    
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
