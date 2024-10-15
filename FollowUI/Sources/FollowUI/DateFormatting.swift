//
//  DateFormatting.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Foundation
import SwiftDate

@MainActor
public class DateFormatting {
    public static let shared = DateFormatting()
    
    private let dateFormatter: DateFormatter
    private let iso8601DateFormatter: ISO8601DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a" // This is equivalent to "lll" in dayjs
        
        iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    public func setDateFormat(_ format: String) {
        dateFormatter.dateFormat = format
    }
    
    public func string(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    public func date(from string: String) -> Date? {
        // First try parsing with ISO8601 formatter
        if let date = iso8601DateFormatter.date(from: string) {
            return date
        }
        // If that fails, try with the regular date formatter
        return dateFormatter.date(from: string)
    }
    
    public func formatTime(date: Date, relativeBeforeDay: Int? = nil, template: String? = nil) -> String {
        if let relativeBeforeDay = relativeBeforeDay {
            let diffInDays = abs(date.timeIntervalSince(Date()) / (24 * 60 * 60))
            if diffInDays > Double(relativeBeforeDay) {
                if let template = template {
                    setDateFormat(template)
                }
                return string(from: date)
            }
        }
    
        let dateInRegion = date.inDefaultRegion()
        return dateInRegion.toRelative(since: nil, dateTimeStyle: .numeric, unitsStyle: .full)
    }
    
    public func formatTime(dateString: String, relativeBeforeDay: Int? = nil, template: String? = nil) -> String {
        guard let date = date(from: dateString) else {
            return "Invalid Date"
        }
        return formatTime(date: date, relativeBeforeDay: relativeBeforeDay, template: template)
    }
}
