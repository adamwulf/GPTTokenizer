//
//  File.swift
//  
//
//  Created by Adam Wulf on 5/12/23.
//

import Foundation
import Locks

public enum GPTTokenizer {

    private static let lock = Mutex()

    // cache is just to speed things up - it keeps tokens that have been found previously
    private static var BPE_CACHE = [String: String]()

    // Hold the dictionary - read from the file
    private static var Encoder = [String: Int]()

    //// --------------------------------------------------------------------
    //// Holds a cache of byte to unicode mappings
    //// --------------------------------------------------------------------
    private static var BYTES_TO_UNICODE_CACHE = [Int: Character]()

    private static func Ord(_ x: String) -> Int {
        return Int(x.unicodeScalars.first!.value)
    }

    private static func BytesToUnicode() -> [Int: Character] {
        // Note: Its been done already - so dont do it again
        if !BYTES_TO_UNICODE_CACHE.isEmpty {
            return BYTES_TO_UNICODE_CACHE
        }

        var bytes = Array(Ord("!")...Ord("~")) + Array(Ord("¡")...Ord("¬")) + Array(Ord("®")...Ord("ÿ"))

        var chars = bytes.map { Character(UnicodeScalar($0)!) }

        var n = 0
        for b in 0..<256 {
            if bytes.contains(b) {
                continue
            }
            bytes.append(b)
            chars.append(Character(UnicodeScalar(256 + n)!))
            n += 1
        }

        BYTES_TO_UNICODE_CACHE = Dictionary(uniqueKeysWithValues: zip(bytes, chars))

        return BYTES_TO_UNICODE_CACHE
    }

    // --------------------------------------------------------------------
    // Cache build end
    // --------------------------------------------------------------------

    private static func BuildDictionary() throws {
        // already loaded
        if !Encoder.isEmpty {
            return
        }

        // Setup a cache that hold a byte/unicode match list
        let byteEncoder = BytesToUnicode()

        // both GPT-3.5 and GPT-4 use cl100k_base
        let cl110kBase = Bundle.module.url(forResource: "cl100k_base", withExtension: "tiktoken")!
        let text = try! String(contentsOfFile: cl110kBase.path, encoding: .utf8)
        let lines = text.replacingOccurrences(of: "\r", with: "").split(separator: "\n")

        for line in lines {
            let bits = line.split(separator: " ")
            if bits.count == 2 {
                let bytelist = Data(base64Encoded: String(bits[0]))!
                let str = String(bytelist.map { byteEncoder[Int($0)]! })
                Encoder[str] = Int(bits[1])!
            }
        }

        Encoder["<|endoftext|>"] = 100257
        Encoder["<|fim_prefix|>"] = 100258
        Encoder["<|fim_middle|>"] = 100259
        Encoder["<|fim_suffix|>"] = 100260
        Encoder["<|endofprompt|>"] = 100276

        if Encoder.isEmpty {
            throw NSError(domain: "cl100kSettings deserialization returned NULL", code: 0, userInfo: nil)
        }
    }

    public static func Encode(_ text: String) throws -> [Int] {
        lock.lock()
        defer { lock.unlock() }
        // nothing to do here
        if text.isEmpty {
            return []
        }

        try BuildDictionary()

        // Setup a cache that hold a byte/unicode match list
        let byteEncoder = BytesToUnicode()

        // Break text down into words
        // regex from tiktoken: https://github.com/openai/tiktoken/blob/095924e02c85617df6889698d94515f91666c7ea/tiktoken_ext/openai_public.py#L76
        let pat = #"(?i:'s|'t|'re|'ve|'m|'ll|'d)|[^\r\n\p{L}\p{N}]?\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]+[\r\n]*|\s*[\r\n]+|\s+(?!\S)|\s+"#
        let matches = try! NSRegularExpression(pattern: pat, options: []).matches(in: text, range: NSRange(text.startIndex..., in: text))

        var bpeTokens = [Int]()

        var combined = [String]()
        for var i in 0..<matches.count {
            let thisvalue = (text as NSString).substring(with: matches[i].range)
            if thisvalue == "<|" && i < matches.count - 2 && (text as NSString).substring(with: matches[i + 2].range) == "|>" {
                combined.append(thisvalue + (text as NSString).substring(with: matches[i + 1].range) + (text as NSString).substring(with: matches[i + 2].range))
                i = i + 2
            } else {
                combined.append(thisvalue)
            }
        }

        // work through each word
        for match in combined {
            // convert utf8 string bytes into unicode string
            let token = String(Data(match.utf8).map { byteEncoder[Int($0)]! })

            if token.hasPrefix("<|") && token.hasSuffix("|>") && Encoder[token] != nil {
                bpeTokens.append(Encoder[token]!)
            } else {
                let newTokensS = BytePairEncoding(token).split(separator: " ").map { String($0) }
                let newTokens = newTokensS.compactMap { Encoder[$0] }
                bpeTokens.append(contentsOf: newTokens)
            }
        }

        return bpeTokens
    }

    private static func BytePairEncoding(_ token: String) -> String {
        if BPE_CACHE[token] != nil {
            return BPE_CACHE[token]!
        }

        var word = token.map { String($0) }
        var pairs = GetPairs(word)
        if pairs.count == 0 {
            BPE_CACHE[token] = token
            return token
        }

        while true {
            var minPairs = Dictionary<Int, (String, String)>()
            for pair in pairs {
                if Encoder[pair.0 + pair.1] != nil {
                    let rank = Encoder[pair.0 + pair.1]!
                    minPairs[rank] = pair
                } else {
                    minPairs[100000000000] = pair
                }
            }

            let biGram = minPairs[minPairs.keys.min()!]!
            if Encoder[biGram.0 + biGram.1] == nil {
                break
            }

            let first = biGram.0
            let second = biGram.1

            var newWord = [String]()
            var i = 0

            while i < word.count {
                let j = word[i...].firstIndex(of: first) ?? word.count

                if j == word.count {
                    newWord.append(contentsOf: word[i...])
                    break
                }

                newWord.append(contentsOf: word[i..<j])
                i = j

                if word[i] == first && i < (word.count - 1) && word[i + 1] == second {
                    newWord.append("\(first)\(second)")
                    i += 2
                } else {
                    newWord.append(word[i])
                    i += 1
                }
            }

            word = newWord
            if word.count == 1 {
                break
            }
            pairs = GetPairs(word)
        }

        let result = word.joined(separator: " ")
        BPE_CACHE[token] = result
        return result
    }

    private static func GetPairs(_ word: [String]) -> [(String, String)] {
        var result = [(String, String)]()

        var prevChar = word[0]
        for i in 1..<word.count {
            let currentChar = word[i]
            result.append((prevChar, currentChar))
            prevChar = currentChar
        }

        return result
    }
}
