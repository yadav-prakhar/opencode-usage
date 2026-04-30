import Foundation

enum CurlParserError: Error, LocalizedError {
    case emptyCommand
    case noURLFound
    case invalidURL(String)
    case noCookieHeader
    case parseFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyCommand:
            return "Curl command is empty"
        case .noURLFound:
            return "No URL found in curl command"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .noCookieHeader:
            return "No Cookie header found. Make sure to copy the full curl command including headers."
        case .parseFailed(let msg):
            return "Parse failed: \(msg)"
        }
    }
}

struct CurlParseResult {
    let url: URL
    let headers: [String: String]
    let cookie: String
}

enum CurlParser {
    /// Parse a full curl command copied from browser DevTools.
    static func parse(_ command: String) throws -> CurlParseResult {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw CurlParserError.emptyCommand
        }

        let tokens = tokenize(trimmed)
        guard tokens.count > 1 else {
            throw CurlParserError.noURLFound
        }

        var urlString: String?
        var headers: [String: String] = [:]
        var cookie: String?

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            // Skip the 'curl' command itself
            if i == 0 && token.lowercased() == "curl" {
                i += 1
                continue
            }

            // Skip common curl flags that don't take values or we don't care about
            if ["--compressed", "-L", "-s", "-S", "-v", "--verbose",
                "-I", "-i", "--include", "-X", "--request",
                "--http1.1", "--http2", "-k", "--insecure"].contains(token) {
                i += 1
                continue
            }

            // Handle -X GET or --request GET
            if (token == "-X" || token == "--request") && i + 1 < tokens.count {
                i += 2
                continue
            }

            // Handle -H 'header: value' or --header 'header: value'
            if token == "-H" || token == "--header" {
                guard i + 1 < tokens.count else {
                    throw CurlParserError.parseFailed("Missing value for \(token)")
                }
                let headerValue = tokens[i + 1]
                if let sepIndex = headerValue.firstIndex(of: ":") {
                    let key = String(headerValue[..<sepIndex]).trimmingCharacters(in: .whitespaces)
                    let value = String(headerValue[headerValue.index(after: sepIndex)...]).trimmingCharacters(in: .whitespaces)
                    let lowercasedKey = key.lowercased()
                    if lowercasedKey == "cookie" {
                        cookie = value
                    } else {
                        headers[key] = value
                    }
                }
                i += 2
                continue
            }

            // If token looks like a URL, capture it
            if token.lowercased().hasPrefix("http://") || token.lowercased().hasPrefix("https://") {
                urlString = token
                i += 1
                continue
            }

            // Skip other flags and their values (generic -x value pattern)
            if token.hasPrefix("-") && token.count == 2 && i + 1 < tokens.count {
                i += 2
                continue
            }
            if token.hasPrefix("--") && i + 1 < tokens.count {
                // Check if next token is a value (doesn't start with -)
                let next = tokens[i + 1]
                if !next.hasPrefix("-") {
                    i += 2
                    continue
                }
            }

            i += 1
        }

        guard let urlStr = urlString else {
            throw CurlParserError.noURLFound
        }
        guard let url = URL(string: urlStr) else {
            throw CurlParserError.invalidURL(urlStr)
        }
        guard let cookieValue = cookie else {
            throw CurlParserError.noCookieHeader
        }

        return CurlParseResult(url: url, headers: headers, cookie: cookieValue)
    }

    // MARK: - Tokenizer

    /// Tokenize a shell command string, respecting single and double quotes.
    private static func tokenize(_ input: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inSingleQuote = false
        var inDoubleQuote = false
        var escaping = false

        for char in input {
            if escaping {
                current.append(char)
                escaping = false
                continue
            }

            if char == "\\" {
                escaping = true
                continue
            }

            if inSingleQuote {
                if char == "'" {
                    inSingleQuote = false
                } else {
                    current.append(char)
                }
                continue
            }

            if inDoubleQuote {
                if char == "\"" {
                    inDoubleQuote = false
                } else {
                    current.append(char)
                }
                continue
            }

            if char == "'" {
                inSingleQuote = true
                continue
            }
            if char == "\"" {
                inDoubleQuote = true
                continue
            }

            if char.isWhitespace {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                continue
            }

            current.append(char)
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }
}
