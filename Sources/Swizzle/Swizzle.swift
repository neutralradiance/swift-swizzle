//
//  SwizzleSwift.swift
//  SizzleSwift
//
//  Created by Mario on 30/07/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

infix operator <->
infix operator <~>

public struct SwizzlePair {
    let old: Selector
    let new: Selector
    var `static` = false
}

extension Selector {
    public static func <->(lhs: Selector, rhs: Selector) -> SwizzlePair {
        SwizzlePair(old: lhs, new: rhs)
    }
    public static func <->(lhs: String, rhs: Selector) -> SwizzlePair {
        SwizzlePair(old: Selector(lhs), new: rhs)
    }
    public static func <~>(lhs: Selector, rhs: Selector) -> SwizzlePair {
        SwizzlePair(old: lhs, new: rhs, static: true)
    }
    public static func <~>(lhs: String, rhs: Selector) -> SwizzlePair {
        SwizzlePair(old: Selector(lhs), new: rhs, static: true)
    }
}

public struct Swizzle {

    @_functionBuilder
    public struct SwizzleBuilder {
        
        public static func buildBlock(_ swizzlePairs: SwizzlePair...) -> [SwizzlePair] {
            Array(swizzlePairs)
        }
    }
    
    @discardableResult
    public init<T>(_ type: T.Type, @SwizzleBuilder _ makeSwizzlePairs: (T.Type) -> [SwizzlePair]) throws where T: AnyObject {
        guard object_isClass(type) else { throw Error.missingClass(String(describing: type)) }
        let swizzlePairs = makeSwizzlePairs(type)
        try swizzle(type: type, pairs: swizzlePairs)
    }

    @discardableResult
    public init(_ string: String, @SwizzleBuilder _ makeSwizzlePairs: () -> [SwizzlePair]) throws {
        guard let type = NSClassFromString(string) else { throw Error.missingClass(string) }
        let swizzlePairs = makeSwizzlePairs()
        try swizzle(type: type, pairs: swizzlePairs)
    }

    private func swizzle(type: AnyObject.Type, pairs: [SwizzlePair]) throws {
        try pairs.forEach { pair in
            guard let `class` = pair.static ? object_getClass(type) : type else {
                throw Error.missingClass(type.description())
            }
            guard
                let lhs = class_getInstanceMethod(`class`, pair.old),
                let rhs = class_getInstanceMethod(`class`, pair.new) else {
                throw Error.missingMethod(pair)
            }

            if pair.static,
               class_addMethod(`class`, pair.old, method_getImplementation(rhs), method_getTypeEncoding(rhs)) {
                class_replaceMethod(`class`, pair.new, method_getImplementation(lhs), method_getTypeEncoding(lhs))
            } else {
                method_exchangeImplementations(lhs, rhs)
            }
        }
    }
}

extension Swizzle {
    enum Error: LocalizedError {
        case missingClass(_ name: String), missingMethod(SwizzlePair)

        static let prefix: String = "SwizzleError: "

        var failureReason: String? {
            switch self {
            case let .missingClass(type):
                return "Missing class: \(type)"
            case let .missingMethod(pair):
                return "Missing method for: \(pair.old) and/or \(pair.new)"
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .missingClass:
                return Self.prefix.appending(failureReason!)
            case .missingMethod:
                return Self.prefix.appending(failureReason!)
            }
        }
    }
}

