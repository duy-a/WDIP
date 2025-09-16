//
//  ParkingSpotMeter.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 16/9/25.
//

import SwiftUI

struct ParkingSpotMeter: View {
    var parkingSpot: ParkingSpot
    
    @State private var isLongTermParking: Bool = false
    @State private var timerEndTime: Date = Calendar.current.startOfDay(for: .now)
    
    @State private var isEnabledReminder: Bool = false
    
    @State private var timer: TimerManager = .init(endTime: .now)
    
    private var effectiveTimerEndTime: Date {
        if isLongTermParking {
            return timerEndTime
        } else {
            let time = Calendar.current.dateComponents([.hour, .minute], from: timerEndTime)
            return Calendar.current.date(byAdding: time, to: parkingSpot.parkingStartTime)!
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Text(parkingSpot.parkingStartTime, format: .dateTime)
                    } label: {
                        Label("Parked time", systemImage: "clock")
                    }
                    
                    if parkingSpot.timerEndTime == nil {
                        Toggle("Long term parking", systemImage: "parkingsign.circle", isOn: $isLongTermParking)
                        
                        DatePicker(selection: $timerEndTime,
                                   displayedComponents: isLongTermParking ? [.date, .hourAndMinute] : [.hourAndMinute])
                        {
                            if isLongTermParking {
                                Label("End Date", systemImage: "calendar")
                            } else {
                                Label("Duration", systemImage: "timer")
                            }
                        }
                    } else {
                        if let timerEndTime = parkingSpot.timerEndTime {
                            LabeledContent {
                                Text(timerEndTime, format: .dateTime)
                            } label: {
                                Label("End time", systemImage: "clock.badge")
                            }
                        }
                        
                        LabeledContent {
                            Text(timer.formatRemainingTime)
                        } label: {
                            Label("Remaining time", systemImage: "timer")
                        }
                    }
                } header: {
                    Text("Meter Timer")
                } footer: {
                    if parkingSpot.timerEndTime == nil, effectiveTimerEndTime < .now {
                        Text("Selected duration has already passed.")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Toggle("Remind me", systemImage: "bell", isOn: $isEnabledReminder)
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("Reminder cannot be set in the past")
                        .foregroundStyle(.red)
                }
            }
            .onAppear {
                setMeter()
            }
            .onDisappear {
                timer.stop()
            }
            .sheetToolbar("Meter Timer & Reminder") {
                ToolbarItem(placement: .topBarTrailing) {
                    if parkingSpot.timerEndTime != nil {
                        Button("Reset meter", systemImage: "stop.fill", action: resetMeter)
                    } else {
                        Button("Set meter", systemImage: "stopwatch", action: setMeter)
                    }
                }
            }
        }
    }
}

extension ParkingSpotMeter {
    private func setMeter() {
        if parkingSpot.timerEndTime == nil, effectiveTimerEndTime > .now {
            parkingSpot.timerEndTime = effectiveTimerEndTime
        } else if let timerEndTime = parkingSpot.timerEndTime, timerEndTime <= .now {
            parkingSpot.timerEndTime = nil
        }
        
        guard let timerEndTime = parkingSpot.timerEndTime else { return }
        timer.endTime = timerEndTime
        timer.onCompletion = resetMeter
        timer.start()
    }

    private func resetMeter() {
        timer.stop()
        
        parkingSpot.timerEndTime = nil
      
        isLongTermParking = false
        timerEndTime = Calendar.current.startOfDay(for: .now)
        
        isEnabledReminder = false
    }
}
