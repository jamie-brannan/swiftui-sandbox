//
//  OldViewController.swift
//  ResizingHybrid
//
//  Created by Jamie Brannan on 18/08/2026.
//

import UIKit
import SwiftUI

/// Our View Controller files need to add imports of SwiftUI
class OldViewController: UIViewController {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Old sad UI View Controller 😢"
    label.font = .preferredFont(forTextStyle: .title2)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private let environmentLabel: UILabel = {
    let label = UILabel()
    label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemTeal

    let stack = UIStackView(arrangedSubviews: [titleLabel, environmentLabel])
    stack.axis = .vertical
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  /// Having a method that can take on 
  func update(
    horizontalSizeClass: UserInterfaceSizeClass?,
    verticalSizeClass: UserInterfaceSizeClass?
  ) {
    environmentLabel.text = """
      horizontalSizeClass: \(horizontalSizeClass?.description ?? "unspecified")
      verticalSizeClass: \(verticalSizeClass?.description ?? "unspecified")
      """
  }
}

private extension UserInterfaceSizeClass {
  var description: String {
    switch self {
    case .compact: "compact"
    case .regular: "regular"
    @unknown default: "unknown"
    }
  }
}

#Preview {
  OldViewController()
}
