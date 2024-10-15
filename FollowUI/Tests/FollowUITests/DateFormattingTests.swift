//
//  DateFormattingTests.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import Testing
@testable import FollowUI

@Test func testDateFormatting() async throws {
    let dateString = "2024-10-15T09:30:00.806Z"
    let formattedString = await DateFormatting.shared.formatTime(dateString: dateString)
    #expect(formattedString == "6 hours ago")
}

