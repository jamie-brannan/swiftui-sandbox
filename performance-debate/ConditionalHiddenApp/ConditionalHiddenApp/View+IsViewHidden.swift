//
//  View+IsViewHidden.swift
//  ConditionalHiddenApp
//
//  The extension under debate.
//

import SwiftUI

extension View {
    /// The function being debated: keeps the view in the hierarchy but calls `.hidden()`.
    @ViewBuilder func isViewHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
