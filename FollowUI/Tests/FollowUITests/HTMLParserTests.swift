//
//  HTMLParserTests.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import Testing
@testable import FollowUI

@Test func testHTMLParser() throws {
    let html = """
    <p style="line-height: 150%; text-align: justify; text-indent: 0em;"><img src="http://image.sciencenet.cn/home/202410/16/205038z35nvr393r3ruvnn.jpg" title="" alt="微信图片_20241016205010.jpg"></p>
    """

    let markdown = try HTMLToMarkdownParser().parseHTML(content: html)
    #expect(markdown == """
    # Hello, World!

    This is a [link](https://example.com) and an image ![Image](https://example
    """)
}
