//
//  ParkingSpot+Timer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import Foundation

extension ParkingSpot {
    func starTimer() {
        guard hasRunningTimer, let endTime = timerEndTime else { return }

        clearTimerTask()

        timerTask = TimerManager.starTimer(endTime: endTime) { remainingTime in
            self.timerRemainingTime = remainingTime
            self.clearReminderIfDelivered()
        } onComplete: {
            self.stopTimer()
            self.cancelReminder()
        }
    }

    func stopTimer() {
        clearTimerTask()

        hasRunningTimer = false
        timerEndTime = nil
        timerRemainingTime = 0
    }

    func clearTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }
}
