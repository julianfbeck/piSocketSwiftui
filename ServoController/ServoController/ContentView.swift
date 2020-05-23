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
    
    @State var numberOfSteps = "0"
    
    @State var direction: Direction = .right
    
    
    
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
                        VStack {                            Text("\((Int(Double(self.model.totalSteps) * 7.2)) % 360)°").font(.title).bold()
                            Spacer()
                            Text("Position").font(.caption).bold()
                            
                        }
                    }
                }.listRowBackground(Color("systemBackground"))
                Section {
                    Stepper(onIncrement: {
                        self.model.step(direction: .right, steps: 1)
                    }, onDecrement: {
                        self.model.step(direction: .left, steps: 1)
                    }) {
                        Text("Step")
                    }
                }
                
                Section {
                    HStack {
                        Text("Number of Steps")
                        Spacer()
                        TextField("0", text: $numberOfSteps).keyboardType(.decimalPad).multilineTextAlignment(.trailing).onTapGesture {
                                   self.endEditing(true)
                                   
                                }
                        
                    }
                    HStack {
                        Text("Speed").padding(.trailing)
                        Slider(value: Binding(
                            get: {
                                self.model.totalSpeed
                        },
                            set: {(newValue) in
                                self.model.setSpeed(speed: newValue)
                        }
                        ), in: 0.001...0.1, step: 0.001)
                    }
                    HStack() {
                        
                        
                        Text("Direction")
                        
                        Spacer(minLength: 48)
                        
                        Picker("Directon", selection: $direction) {
                             ForEach(Direction.allCases, id: \.self) {
                                   Text($0.rawValue)
                               }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Button(action: {
                        self.model.step(direction: self.direction, steps: Int(self.numberOfSteps)!)
                    }) {
                        Text("GO!")
                    }
                }
                Button(action: {
                    self.model.resetPosition()
                }) {
                    Text("Reset Position")
                }
                
                Section {
                    if model.isStopped {
                        Button(action: {
                            self.model.go()
                        }) {
                            Text("Resume Stepper").foregroundColor(.green)
                                .bold()
                        }
                    } else {
                        Button(action: {
                            self.model.stop()
                        }) {
                            Text("Stop Stepper").foregroundColor(.red)
                                .bold()
                        }
                    }

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

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}
