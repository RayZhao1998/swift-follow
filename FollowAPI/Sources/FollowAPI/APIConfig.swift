import Foundation

public struct APIConfig {
    static let baseURL = URL(string: "https://api.follow.is")!
    
    static let cookie = "authjs.csrf-token=d5051ca2ef2ff16aa25d9084734784a93e0c5ad4920f2d48b037f68c304a254a%7C504b4d19cdad22c0126377904054446b75092dc7c92597902a6d9b8662602f75; authjs.callback-url=https%3A%2F%2Fapp.follow.is%2Fredirect%3Fapp%3Dfollow; authjs.session-token=e03fa6bc-4763-413a-b2a8-d8dd9a017974; ph_phc_EZGEvBt830JgBHTiwpHqJAEbWnbv63m5UpreojwEWNL_posthog=%7B%22distinct_id%22%3A%2258054760722430976%22%2C%22%24sesid%22%3A%5B1729003155097%2C%220192909b-a66b-74b0-a468-13b80bfb7a8b%22%2C1729002972779%5D%2C%22%24epp%22%3Atrue%7D"
    
    static let csrfToken = "d5051ca2ef2ff16aa25d9084734784a93e0c5ad4920f2d48b037f68c304a254a"
    
    static var headers: [String: String] {
        return ["Cookie": cookie]
    }
}
