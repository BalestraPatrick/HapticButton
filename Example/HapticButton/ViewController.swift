//
//  ViewController.swift
//  HapticButton
//
//  Created by BalestraPatrick on 06/23/2017.
//  Copyright (c) 2017 BalestraPatrick. All rights reserved.
//

import UIKit
import HapticButton

class ViewController: UIViewController {

    @IBOutlet weak var button: HapticButton!
    @IBOutlet weak var blurButton: HapticButton!
    @IBOutlet weak var darkBlurButton: HapticButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        button.mode = .label(text: "Hello! 👋")
        // Use the delegate method to be notified when the button is pressed.
        button.delegate = self

        blurButton.mode = .image(image: #imageLiteral(resourceName: "swift"))
        blurButton.addBlurView(style: .light)
        // Add custom target selector to the touch up inside event.
        blurButton.addTarget(self, action: #selector(blurButtonPressed(_:)), for: .touchUpInside)

        darkBlurButton.mode = .label(text: "Hello Blur!")
        darkBlurButton.textLabel.textColor = .white
        darkBlurButton.addBlurView(style: .dark)
        // Pass closure to be invoked when the button is pressed.
        darkBlurButton.onPressed = {
            print("Dark blur button pressed.")
        }
    }

    func blurButtonPressed(_ sender: HapticButton) {
        print("Light blur button pressed.")
    }
}

extension ViewController: HapticButtonDelegate {

    func pressed(sender: HapticButton) {
        print("White button pressed.")
    }
}
