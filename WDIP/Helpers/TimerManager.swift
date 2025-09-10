//
//  TimerManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import Foundation

enum TimerManager {
    @discardableResult
    static func starTimer(
        endTime: Date,
        onTick: @MainActor @escaping (TimeInterval) -> Void,
        onComplete: @MainActor @escaping () -> Void
    ) -> Task<Void, Never> {
        Task { @MainActor in
            var nextTick = ContinuousClock.now

            while !Task.isCancelled {
                let remaining = endTime.timeIntervalSinceNow
                onTick(max(remaining, 0)) // clamp at 0 to avoid negatives

                guard remaining > 0 else {
                    onComplete()
                    break
                }

                nextTick = nextTick.advanced(by: .seconds(1))
                try? await Task.sleep(until: nextTick, clock: .continuous)
            }
        }
    }

    static func formatRemainingTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
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
}
