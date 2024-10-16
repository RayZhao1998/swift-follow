//
//  HTMLParser.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import Foundation
import SwiftSoup

class HTMLToMarkdownParser {
    
    func parseHTML(content: String) throws -> String {
        let document = try SwiftSoup.parse(content)
        return try convertToMarkdown(element: document.body()!)
    }
    
    private func convertToMarkdown(element: Element) throws -> String {
        var markdown = ""
        
        for child in element.children() {
            do {
                switch child.tagName() {
                case "p":
                    let pContent = try handleParagraphContent(child)
                    markdown += "\n\n\(pContent)\n\n"
                case "h1", "h2", "h3", "h4", "h5", "h6":
                    let level = Int(child.tagName().dropFirst())!
                    markdown += "\n\n\(String(repeating: "#", count: level)) \(try child.text())\n\n"
                case "a":
                    let href = try child.attr("href")
                    markdown += "[\(try child.text())](\(href))"
                case "img":
                    markdown += try handleImage(child)
                case "ul", "ol":
                    markdown += "\n\(try parseList(element: child))\n"
                case "pre":
                    if let code = try child.select("code").first() {
                        let language = try code.className().replacingOccurrences(of: "language-", with: "")
                        markdown += "\n\n```\(language)\n\(try code.text())\n```\n\n"
                    }
                case "blockquote":
                    markdown += "\n\n> \(try child.text().replacingOccurrences(of: "\n", with: "\n> "))\n\n"
                default:
                    markdown += try convertToMarkdown(element: child)
                }
            } catch {
                // 在这里处理错误，可以选择忽略错误并继续，或者记录错误
                print("Error processing element \(child.tagName()): \(error)")
                // 可以选择添加一些标记来指示解析错误
                markdown += "\n[解析错误]\n"
            }
        }
        
        return markdown
    }
    
    private func parseList(element: Element) throws -> String {
        var listItems = ""
        let isOrdered = element.tagName() == "ol"
        
        for (index, item) in element.children().enumerated() {
            if item.tagName() == "li" {
                let prefix = isOrdered ? "\(index + 1). " : "- "
                listItems += "\(prefix)\(try item.text())\n"
            }
        }
        
        return listItems
    }
    
    private func handleParagraphContent(_ paragraph: Element) throws -> String {
        var content = ""
        for child in paragraph.children() {
            if child.tagName() == "img" {
                content += try handleImage(child)
            } else {
                content += try child.text()
            }
        }
        return content.isEmpty ? try paragraph.text() : content
    }
    
    private func handleImage(_ img: Element) throws -> String {
        let src = try img.attr("src").replaceImgUrlIfNeed()
        let alt = try img.attr("alt")
        return "![\(alt)](\(src))"
    }
}

// Usage example:
// let parser = HTMLToMarkdownParser()
// let htmlContent = "<h1>Hello, World!</h1><p>This is a paragraph.</p>"
// do {
//     let markdown = try parser.parseHTML(content: htmlContent)
//     print(markdown)
// } catch {
//     print("Error parsing HTML: \(error)")
// }
