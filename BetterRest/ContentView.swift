//
//  ContentView.swift
//  BetterRest
//
//  Created by artembolotov on 02.01.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    private var bedTime: Date? {
        get {
            calculateBedTime()
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                }

                Section {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1...21, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                }
                VStack(alignment: .leading) {
                    Text("Your ideal bedtime is:")
                    Text(bedTime == nil ? "Error calculating your ideal bedtime" : bedTime!.formatted(date: .omitted, time: .shortened))
                }
                
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedTime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
        } catch {
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
