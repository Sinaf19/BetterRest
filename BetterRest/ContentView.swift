//
//  ContentView.swift
//  BetterRest
//
//  Created by Quentin Surdez on 19.01.24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up ?")
                        .font(.headline)
                    
                    DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            
        }
        showingAlert = true
    }
    
//    func exampleDates() {
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let data = Calendar.current.date(from: components) ?? .now
//
//        let components = Calendar.current.dateComponents([.hour, .minute], from: someDate)
//        let hour = components.hour ?? 0
//        let minute = components.minute ?? 0
//
//        Text(Date.now, format: .dateTime.day().month().year())
//        Text(Date.now.formatted(date: .long, time: .shortened))
//    }
}

#Preview {
    ContentView()
}
