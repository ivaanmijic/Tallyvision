//
//  ScrollableStackView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 4. 12. 2024..
//

import UIKit

class ScrollableStackView: UIView {

    // MARK: Properties

        private var didSetupConstraints = false

        private lazy var scrollView: UIScrollView = {
            let scrollView = UIScrollView(frame: .zero)
            scrollView.backgroundColor = .clear
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.layoutMargins = .zero
            return scrollView
        }()

        private lazy var stackView: UIStackView = {
            let stackView = UIStackView(frame: .zero)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            return stackView
        }()

        // MARK: Life Cycle

        public override func didMoveToSuperview() {
            super.didMoveToSuperview()
            translatesAutoresizingMaskIntoConstraints = false
            clipsToBounds = true
            addSubview(scrollView)
            scrollView.addSubview(stackView)
            setNeedsUpdateConstraints()
        }

        public override func updateConstraints() {
            super.updateConstraints()
            if !didSetupConstraints {
                NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalTo: topAnchor),
                    scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                ])
                didSetupConstraints.toggle()
            }
        }

    }

    // MARK: - ScrollableStackView - Actions

extension ScrollableStackView {
    /// Adds a view to the end of the arranged subviews array.
    ///
    /// - Parameter view: The view to be added to the array of views arranged by the stack.
    public func add(view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    /// Adds the provided view to the array of arranged subviews at the specified index.
    ///
    /// - Parameters:
    ///   - view: The view to be added to the array of views arranged by the stack.
    ///   - index: The index where the stack inserts the new view in its arranged subviews array.
    ///     This value must not be greater than the number of views currently in this array.
    ///     If the index is out of bounds, this method throws an `internalInconsistencyException` exception.
    public func insert(view: UIView, at index:  Int) {
        stackView.insertArrangedSubview(view, at: index)
    }
    
    /// Removes the provided view from the stack’s array of arranged subviews.
    ///
    /// - Parameter view: The view to be removed from the array of views arranged by the stack.
    public func remove(view: UIView) {
        stackView.removeArrangedSubview(view)
    }
    
}
