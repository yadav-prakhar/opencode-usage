import Foundation

enum Config {
    static let apiURL = URL(string: "https://opencode.ai/_server?id=c7389bd0e731f80f49593e5ee53835475f4e28594dd6bd83eb229bab753498cd&args=%7B%22t%22%3A%7B%22t%22%3A9%2C%22i%22%3A0%2C%22l%22%3A1%2C%22a%22%3A%5B%7B%22t%22%3A1%2C%22s%22%3A%22wrk_01KKC7847TTAF649VFQNBH8JQ6%22%7D%5D%2C%22o%22%3A0%7D%2C%22f%22%3A31%2C%22m%22%3A%5B%5D%7D")!
    
    static let authCookie = "oc_locale=en; auth=Fe26.2**baf9bdac35f24b3ca2dd3b293f339b2f40e72ffb6ebac43bc18a5c16eaa83244*ZMBm_-Ke3d3qDiq_kqUEZg*x50ET-ni7z8cYenkfcSxATx9cUL8rG9VHdGdymaVamyOVRMpMIBsen9V8IXdXenSbzg8zrNA2L4oR84xDYZaBkbMeKr0LDNUXrXYyhZPBeIP13OdddJnTlDPz_c5qada79gc3BFwWIL2hoY2ChN_cc_fA0GYFH8mhbGxESlUHNuqD0TMzErQiBR4AOB3nix-eGNTZwLl2XTZE78JzThLyyxnQ9w8n5K0a9quE0aeayvL5SXTEXa7r2VNWQwSm2WDeZ7iCp035HBKVFnPFU2gM0KIx3XgEwocfDsfE7q0YoWr-nsUt0lF3wfrozcpZCAvbo7eHIsTr5KUONpU8rsO7Q*1804694013653*1649ba3ccad3561eef8ada96a17bbeb2e4d29786af050ad4841f1c3251f6d29e*RnZIQeyaX4HjJWoYTVjvMGwmbDsH3nO4AKs8Re8q7bo"
    
    static let headers: [String: String] = [
        "accept": "*/*",
        "accept-language": "en-US,en;q=0.9,id;q=0.8",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36",
        "x-server-id": "c7389bd0e731f80f49593e5ee53835475f4e28594dd6bd83eb229bab753498cd",
        "x-server-instance": "server-fn:4"
    ]
}
