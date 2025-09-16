//
//  ParkingSpotMeter.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 16/9/25.
//

import SwiftUI

struct ParkingSpotMeter: View {
    @Environment(NotificationManager.self) var notificationManager
    
    var parkingSpot: ParkingSpot
    
    @State private var isLongTermParking: Bool = false
    @State private var timerEndTime: Date = Calendar.current.startOfDay(for: .now)
    
    @State private var isEnabledReminder: Bool = false
    @State private var isShowingPermissionDeniedAlert: Bool = false
    @State private var reminderOption: ParkingSpot.ReminderTimeOption = .before5min
    @State private var reminderTime: Date = .now
    
    @State private var timer: TimerManager = .init(endTime: .now)
    
    private var effectiveTimerEndTime: Date {
        if isLongTermParking {
            return timerEndTime
        } else {
            let time = Calendar.current.dateComponents([.hour, .minute], from: timerEndTime)
            return Calendar.current.date(byAdding: time, to: parkingSpot.parkingStartTime)!
        }
    }
    
    private var isValidReminderTime: Bool {
        if let timerEndTime = parkingSpot.timerEndTime {
            return calculatedReminderTime <= timerEndTime
        } else {
            return calculatedReminderTime <= timerEndTime
        }
    }
    
    private var latestReminderDate: Date {
        if let timerEndTime = parkingSpot.timerEndTime {
            return timerEndTime
        } else {
            if timerEndTime > .now {
                return timerEndTime
            } else {
                return .now
            }
        }
    }
    
    private var calculatedReminderTime: Date {
        switch reminderOption {
        case .before5min, .before10min, .before15min, .atTheEnd:
            return Calendar.current.date(byAdding: .minute,
                                         value: -reminderOption.rawValue,
                                         to: latestReminderDate)!
        case .custom:
            return reminderTime
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
                            .onChange(of: isLongTermParking) {
                                if isLongTermParking {
                                    timerEndTime = .now
                                } else {
                                    timerEndTime = Calendar.current.startOfDay(for: .now)
                                }
                            }
                        
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
                        .onChange(of: isEnabledReminder) {
                            isEnabledReminder ? requestNotificationPermission() : cancelReminder()
                        }
                    
                    if isEnabledReminder {
                        Picker(selection: $reminderOption) {
                            ForEach(ParkingSpot.ReminderTimeOption.allCases) { option in
                                Text(option.label).tag(option)
                            }
                        } label: {
                            Label("Time", systemImage: "clock.badge.exclamationmark")
                        }
                        .disabled(parkingSpot.reminderEndTime != nil)
                        
                        if reminderOption == .custom {
                            DatePicker(selection: $reminderTime, in: .now ... latestReminderDate) {
                                Label("", systemImage: "calendar")
                            }
                            .disabled(parkingSpot.reminderEndTime != nil)
                        }
                        
                        if parkingSpot.timerEndTime != nil && parkingSpot.reminderEndTime == nil {
                            Button("Set reminder", systemImage: "alarm", action: scheduleReminder)
                                .disabled(isEnabledReminder && calculatedReminderTime < .now)
                        }
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    if isEnabledReminder, calculatedReminderTime < .now {
                        Text("Reminder cannot be set in the past")
                            .foregroundStyle(.red)
                    }
                }
            }
            .onAppear {
                setInitialsValues()
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
            .alert("Notifications Disabled", isPresented: $isShowingPermissionDeniedAlert) {
                Button("Open Settings", action: openAppSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable notifications in Settings to recieve reminders")
            }
        }
    }
}

extension ParkingSpotMeter {
    private func setInitialsValues() {
        if let timerEndTime = parkingSpot.timerEndTime {
            self.timerEndTime = timerEndTime
            timer.endTime = timerEndTime
            timer.onCompletion = resetMeter
            timer.start()
        }
        
        if let reminderTime = parkingSpot.reminderEndTime, let reminderOption = parkingSpot.reminderOption {
            isEnabledReminder = true
            self.reminderTime = reminderTime
            self.reminderOption = ParkingSpot.ReminderTimeOption(rawValue: reminderOption)!
        }
    }
    
    private func setMeter() {
        if parkingSpot.timerEndTime == nil, effectiveTimerEndTime > .now {
            parkingSpot.timerEndTime = effectiveTimerEndTime
        } else if parkingSpot.timerEndTime != nil, timerEndTime <= .now {
            parkingSpot.timerEndTime = nil
        }

        guard let timerEndTime = parkingSpot.timerEndTime else { return }
        timer.endTime = timerEndTime
        timer.onTick = checkIfNotificationDelivered
        timer.onCompletion = resetMeter
        timer.start()
        
        scheduleReminder()
    }

    private func resetMeter() {
        timer.stop()
        
        parkingSpot.timerEndTime = nil
      
        isLongTermParking = false
        timerEndTime = Calendar.current.startOfDay(for: .now)
                
        cancelReminder()
    }
    
    private func requestNotificationPermission() {
        Task { @MainActor in
            await notificationManager.requestPermission()

            if !notificationManager.isAuthorized {
                isShowingPermissionDeniedAlert = true
                parkingSpot.reminderEndTime = nil
            }
        }
    }
    
    private func scheduleReminder() {
        guard isEnabledReminder, isValidReminderTime else { return }
        
        parkingSpot.reminderEndTime = calculatedReminderTime
        parkingSpot.reminderOption = reminderOption.rawValue
        
        var notificationBody = ""
        
        switch reminderOption {
        case .before5min, .before10min, .before15min:
            notificationBody = "Your parking meter will expire in \(reminderOption.rawValue) minutes."
        case .atTheEnd:
            notificationBody = "Your parking meter has expired."
        case .custom:
            if parkingSpot.reminderEndTime == parkingSpot.timerEndTime {
                notificationBody = "Your parking meter has expired."
            } else {
                notificationBody = "Your parking meter will expire on \(reminderTime.formatted(date: .abbreviated, time: .shortened))"
            }
        }
        
        Task {
            await notificationManager.scheduleNotification(id: parkingSpot.notificationId,
                                                           title: parkingSpot.vehicle?.name ?? "Your vehicle",
                                                           body: notificationBody,
                                                           date: calculatedReminderTime)
        }
    }
    
    private func checkIfNotificationDelivered() {
        if let reminderTime = parkingSpot.reminderEndTime, reminderTime < .now {
            cancelReminder()
        }
    }
    
    private func cancelReminder() {
        isEnabledReminder = false
        reminderOption = .before5min
        reminderTime = .now
        
        parkingSpot.reminderOption = nil
        parkingSpot.reminderEndTime = nil
        
        notificationManager.cancelNotification(id: parkingSpot.notificationId)
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url)
    }
}
