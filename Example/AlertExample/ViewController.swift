//
//  ViewController.swift
//  AlertExample
//
//  Created by 秋星桥 on 2/22/25.
//

import AlertController
import ConfigurableKit
import UIKit

class ViewController: UIViewController {
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Open Sheet", for: .normal)
        button.addTarget(self, action: #selector(openPanel), for: .touchUpInside)
        view.addSubview(button)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        button.sizeToFit()
        button.center = view.center
    }

    @objc func openPanel() {
        let panel = ConfigurableSheetController(manifest: .init(list: [
            .init(icon: "circle", title: "Open Alert w/ 1", ephemeralAnnotation: .action { controller in
                let alert = AlertViewController(
                    title: "Hello World",
                    message: "This is a message"
                ) { context in
                    context.addAction(title: "Delete", attribute: .dangerous) {
                        context.dispose { print("deleted") }
                    }
                }
                controller?.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ 2", ephemeralAnnotation: .action { controller in
                let alert = AlertViewController(
                    title: "Hello World",
                    message: "This is a message"
                ) { context in
                    context.addAction(title: "Cancel") {
                        context.dispose { print("cancelled") }
                    }
                    context.addAction(title: "Delete", attribute: .dangerous) {
                        context.dispose { print("deleted") }
                    }
                }
                controller?.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ 3", ephemeralAnnotation: .action { controller in
                let alert = AlertViewController(
                    title: "Hello World",
                    message: "This is a message"
                ) { context in
                    context.addAction(title: "Cancel") {
                        context.dispose { print("cancelled") }
                    }
                    context.addAction(title: "Delete", attribute: .dangerous) {
                        context.dispose { print("deleted") }
                    }
                    context.addAction(title: "Delete", attribute: .dangerous) {
                        context.dispose { print("deleted") }
                    }
                }
                controller?.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ Input", ephemeralAnnotation: .action { controller in
                let alert = AlertInputViewController(
                    title: "Hello World",
                    message: "You are going to input a text.",
                    placeholder: "sth...",
                    text: ""
                ) { text in print(text) }
                controller?.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ Progress", ephemeralAnnotation: .action { controller in
                let alert = AlertProgressIndicatorViewController(
                    title: "Hello World",
                    message: "This is a message from alert."
                )
                controller?.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alert.dismiss(animated: true)
                }
            }),
        ]))
        present(panel, animated: true)
    }
}
