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

        } onComplete: {
            self.stopTimer()
        }
    }

    func stopTimer() {
        clearTimerTask()

        hasRunningTimer = false
        timerEndTime = nil
    }

    func clearTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }
}
