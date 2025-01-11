//
//  Symbols.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 1/12/23.
//

import Foundation

public struct Category: Identifiable {
    public let id: String
    public let icon: String
}

/// Simple singleton class for providing symbols list per platform availability.
@MainActor
public class Symbols: Sendable {
    private init() {
        let filename = if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            "sfsymbol6"
        } else if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            "sfsymbol5"
        } else {
            "sfsymbol4"
        }
        if #available(macOS 13.0, *), let (symbolsByCategory, allSymbols) = Self.fetchSymbolsFromSystem() ?? Self.fetchSymbolsFromBundle() {
            self.symbolsByCategory = symbolsByCategory
            self.allSymbols = allSymbols
            categories = Self.fetchCategories()
        } else {
            symbolsByCategory = [:]
            categories = []
            allSymbols = Self.fetchSymbols(fileName: filename)
        }
        symbols = allSymbols
    }

    /// Singleton instance.
    public static let shared = Symbols()

    public let categories: [Category]

    /// Filter closure that checks each symbol name string should be included.
    public var filter: ((String) -> Bool)? {
        didSet {
            if let filter {
                symbols = allSymbols.filter(filter)
            } else {
                symbols = allSymbols
            }
        }
    }

    /// Array of the symbol name strings to be displayed.
    private(set) var symbols: [String]

    private(set) var symbolsByCategory: [String: [String]]

    private static let UNWANTED_CATEGORIES = ["whatsnew", "variablecolor", "multicolor"]

    /// Array of all available symbol name strings.
    private let allSymbols: [String]

    @available(macOS 13.0, *)
    private static func fetchSymbols(plist: NSDictionary) -> ([String: [String]], [String])? {
        var symbolsByCategory = [String: [String]]()
        var allSymbols = [String]()
        let symbols = (plist as? [String: [String]]) ?? [:]

        for (symbol, categories) in symbols {
            for category in categories {
                if symbolsByCategory[category] == nil {
                    symbolsByCategory[category] = [String]()
                }
                symbolsByCategory[category]!.append(symbol)
            }
            allSymbols.append(symbol)
        }

        return (symbolsByCategory.mapValues { $0.sorted() }, allSymbols.sorted())
    }
    private static func fetchCategories() -> [Category] {
        let bundle = Bundle(path: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle") ?? Bundle.module
        guard let resourcePath = bundle.path(forResource: "categories", ofType: "plist"),
              let plist = NSArray(contentsOfFile: resourcePath)
        else {
            return []
        }

        let cats = (plist as? [[String: String]]) ?? []
        return cats
            .filter { !UNWANTED_CATEGORIES.contains($0["key"] ?? "") }
            .map { cat in
                Category(id: cat["key"] ?? "", icon: cat["icon"] ?? "")
            }
    }
    private static func fetchSymbolsFromBundle() -> ([String: [String]], [String])? {
        guard let path = Bundle.module.path(forResource: "symbol_categories", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path)
        else {
            return nil
        }
        return fetchSymbols(plist: plist)
    }

    private static func fetchSymbolsFromSystem() -> ([String: [String]], [String])? {
        guard let bundle = Bundle(path: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle"),
              let resourcePath = bundle.path(forResource: "symbol_categories", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: resourcePath)
        else {
            return nil
        }
        return fetchSymbols(plist: plist)
    }

    private static func fetchSymbols(fileName: String) -> [String] {
        guard let path = Bundle.module.path(forResource: fileName, ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            #if DEBUG
                assertionFailure("[SymbolPicker] Failed to load bundle resource file.")
            #endif
            return []
        }
        return content
            .split(separator: "\n")
            .map { String($0) }
    }

}
