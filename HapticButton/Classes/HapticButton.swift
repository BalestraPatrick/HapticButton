//
//  HapticButton.swift
//  https://github.com/BalestraPatrick/HapticButton
//
//  Created by Patrick Balestra on 6/23/17.
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import UIKit

public typealias Callback = () -> Void

public protocol HapticButtonDelegate: class {
    /// A press happens when the touch pressure is higher than the defined threshold (defaultvalue is 0.25).
    func pressed(sender: HapticButton)
}

/// Describe the button mode cases.
public enum HapticButtonMode {
    case label(_: String)
    case image(_: UIImage)
}

open class HapticButton: UIControl {

    /// The delegate for this button.
    public weak var delegate: HapticButtonDelegate?

    /// The closure invoked when the button is pressed.
    public var onPressed: Callback?

    /// The minium pressure that the button press has to receive in order to trigger the related haptic feedback. The value has to be between 0 and 1 and the default is 0.25.
    public var feedbackThreshold = 0.25

    /// If the button is in mode `label`, this `UILabel` is part of the button hierarchy. Modify this object directly for more customizations on the displayed text.
    public lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Press Me!"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        return label
    }()

    /// If the button is in mode `image`, this `UIImageView` is part of the button hierarchy. Modify this object directly for more customizations on the displayed image.
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    /// The insets of the content (UIImageView or UILabel).
    public var contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    /// The current mode of the button.
    public var mode = HapticButtonMode.label("Title") {
        didSet {
            // Update the UI state based on the current mode.
            switch mode {
            case .image(let image):
                if textLabel.superview != nil {
                    textLabel.removeFromSuperview()
                }
                imageView.image = image
                self.addSubview(imageView)
                imageView.constrainEdges(to: self, insets: contentEdgeInsets)
            case .label(let text):
                if imageView.superview != nil {
                    imageView.removeFromSuperview()
                }
                textLabel.text = text
                self.addSubview(textLabel)
                textLabel.constrainEdges(to: self, insets: contentEdgeInsets)
            }
        }
    }

    /// Keep the last impact date to avoid triggering the haptic feedback multiple times in the same press. In this way, at most one feedback per touch is sent to the user.
    private var lastImpact = Date(timeIntervalSince1970: 0)

    private lazy var generator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.medium)
    }()

    private lazy var blurView: UIVisualEffectView = {
        return UIVisualEffectView(effect: nil)
    }()

    /// Closure invoked when the touch pressure is higher than the defined thresold.
    private lazy var completionBlock: () -> Void = {
        return {
            if self.traitCollection.forceTouchCapability == .available {
                self.generator.impactOccurred()
            }

            if let delegate = self.delegate {
                delegate.pressed(sender: self)
            } else if let pressed = self.onPressed {
                pressed()
            } else {
                self.sendActions(for: .touchUpInside)
            }
            // Complete animation since touchesEnded is not called when immediately presenting a view and if the user doesn't release the touch.
            self.touchesEnded([], with: nil)
        }
    }()

    public convenience init(mode: HapticButtonMode, contentEdgeInsets: UIEdgeInsets = .zero) {
        self.init(frame: .zero)
        // Workaround for Swift "bug" that doesn't call didSet when setting from an initializer. May broke in the future.
        self.contentEdgeInsets = contentEdgeInsets
        defer {
            self.mode = mode
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 30
        layer.masksToBounds = true
    }

    /// Adds a `UIVisualEffectView` with the given `UIBlurEffectStyle` as the background.
    public func addBlurView(style: UIBlurEffectStyle) {
        backgroundColor = .clear
        blurView.effect = UIBlurEffect(style: style)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        blurView.constrainEdges(to: self)
    }

    /// Remove the `UIVisualEffectView` from the background and sets it as white. If you want to restore the previous backgroundColor, you must do so manually.
    public func removeBlurView() {
        backgroundColor = .white
        blurView.removeFromSuperview()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if traitCollection.forceTouchCapability == .available {
            generator.prepare()
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let rate = touch.force / touch.maximumPossibleForce
            let scaling = 1.0 + (rate / 4) + 0.15
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform(scaleX: scaling, y: scaling)
            }
            if Double(rate) >= feedbackThreshold {
                throttle(interval: 1, action: completionBlock)
            }
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10.0, options: [], animations: {
            self.transform = .identity
        })
    }

    private func throttle(interval: TimeInterval, action: () -> Void) {
        let now = Date()
        if now.compare(lastImpact.addingTimeInterval(interval)) == ComparisonResult.orderedDescending {
            action()
            lastImpact = now
        }
    }
}

extension UIView {

    func constrainEdges(to superview: UIView, insets: UIEdgeInsets = .zero) {
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[subview]-\(insets.right)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(insets.top)-[subview]-\(insets.bottom)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
