//
//  Sizing.swift
//  FrameSizingApp
//
//  The Sizing enum from the issue, plus the CGFloat static-extension alternative.
//

import CoreFoundation

// MARK: - Approach A: Sizing enum (rawValue: CGFloat)

/// Design-system sizing tokens.
/// Usage: `Sizing.s8.rawValue`
public enum Sizing: CGFloat, CaseIterable {
    /// 1 pt
    case s1   = 1.0
    /// 2 pt
    case s2   = 2.0
    /// 4 pt
    case s4   = 4.0
    /// 8 pt
    case s8   = 8.0
    /// 12 pt
    case s12  = 12.0
    /// 16 pt
    case s16  = 16.0
    /// 24 pt
    case s24  = 24.0
    /// 32 pt
    case s32  = 32.0
    /// 48 pt
    case s48  = 48.0
    /// 64 pt
    case s64  = 64.0
    /// 80 pt
    case s80  = 80.0
    /// 96 pt
    case s96  = 96.0
    /// 120 pt
    case s120 = 120.0

    /// Human-readable label used in picker UI.
    var label: String { "\(Int(rawValue)) pt" }
}

// MARK: - Approach B: CGFloat static extensions

/// Mirrors every `Sizing` case as a `CGFloat` static constant so that
/// the token can be passed directly to native modifiers:
///
/// ```swift
/// view.frame(width: .s48, height: .s48)
/// view.padding(.s16)
/// ```
public extension CGFloat {
    /// 1 pt — mirrors `Sizing.s1`
    static let s1:   CGFloat = 1.0
    /// 2 pt — mirrors `Sizing.s2`
    static let s2:   CGFloat = 2.0
    /// 4 pt — mirrors `Sizing.s4`
    static let s4:   CGFloat = 4.0
    /// 8 pt — mirrors `Sizing.s8`
    static let s8:   CGFloat = 8.0
    /// 12 pt — mirrors `Sizing.s12`
    static let s12:  CGFloat = 12.0
    /// 16 pt — mirrors `Sizing.s16`
    static let s16:  CGFloat = 16.0
    /// 24 pt — mirrors `Sizing.s24`
    static let s24:  CGFloat = 24.0
    /// 32 pt — mirrors `Sizing.s32`
    static let s32:  CGFloat = 32.0
    /// 48 pt — mirrors `Sizing.s48`
    static let s48:  CGFloat = 48.0
    /// 64 pt — mirrors `Sizing.s64`
    static let s64:  CGFloat = 64.0
    /// 80 pt — mirrors `Sizing.s80`
    static let s80:  CGFloat = 80.0
    /// 96 pt — mirrors `Sizing.s96`
    static let s96:  CGFloat = 96.0
    /// 120 pt — mirrors `Sizing.s120`
    static let s120: CGFloat = 120.0
}
