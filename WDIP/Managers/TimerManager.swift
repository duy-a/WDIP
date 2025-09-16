//
//  TimerManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 16/9/25.
//

import Foundation

@Observable
class TimerManager {
    var remainingTime: TimeInterval = 0
    private var task: Task<Void, Never>?
    var endTime: Date
    var onTick: (() -> Void)?
    var onCompletion: (() -> Void)?

    init(endTime: Date) {
        self.endTime = endTime
    }

    var formatRemainingTime: String {
        let totalSeconds = max(Int(remainingTime), 0)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    func start() {
        task?.cancel()
        task = Task { @MainActor in
            var nextTick = ContinuousClock.now

            while !Task.isCancelled {
                remainingTime = endTime.timeIntervalSinceNow
                onTick?()

                if remainingTime <= 0 {
                    remainingTime = 0
                    onCompletion?()
                    break
                }

                nextTick = nextTick.advanced(by: .seconds(1))
                try? await Task.sleep(until: nextTick, clock: .continuous)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    deinit {
        stop()
    }
}
