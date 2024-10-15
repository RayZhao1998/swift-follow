//
//  ImageProxy.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Foundation

struct ImageProxyConfig {
    static let IMAGE_PROXY_URL = "https://webp.follow.is"
    
    struct RefererMatch {
        let url: NSRegularExpression
        let referer: String
    }
    
    struct WebpCloudMatch {
        let url: NSRegularExpression
        let target: String
    }
    
    static let imageRefererMatches: [RefererMatch] = [
        RefererMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/\\w+\\.sinaimg\\.cn"), referer: "https://weibo.com"),
        RefererMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/i\\.pximg\\.net"), referer: "https://www.pixiv.net"),
        RefererMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/cdnfile\\.sspai\\.com"), referer: "https://sspai.com"),
        RefererMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/(?:\\w|-)+\\.cdninstagram\\.com"), referer: "https://www.instagram.com"),
        RefererMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/sp1\\.piokok\\.com"), referer: "https://sp1.piokok.com")
    ]
    
    static let webpCloudPublicServicesMatches: [WebpCloudMatch] = [
        WebpCloudMatch(url: try! NSRegularExpression(pattern: "^https:\\/\\/avatars\\.githubusercontent\\.com\\/u\\/"),
                       target: "https://avatars-githubusercontent.webp.se/u/")
    ]
}

public extension String {
    func replaceImgUrlIfNeed() -> String {
        guard !self.isEmpty else { return self }
        
        for rule in ImageProxyConfig.webpCloudPublicServicesMatches {
            if let _ = rule.url.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
                return rule.url.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: rule.target)
            }
        }
        
        for rule in ImageProxyConfig.imageRefererMatches {
            if let _ = rule.url.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
                return getImageProxyUrl(url: self, width: 0, height: 0)
            }
        }
        
        return self
    }
    
    private func getImageProxyUrl(url: String, width: Int, height: Int) -> String {
        return "\(ImageProxyConfig.IMAGE_PROXY_URL)?url=\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&width=\(width)&height=\(height)"
    }
}

public extension URL {
    func replaceImgUrlIfNeed() -> URL {
        let replacedString = self.absoluteString.replaceImgUrlIfNeed()
        return URL(string: replacedString) ?? self
    }
}
