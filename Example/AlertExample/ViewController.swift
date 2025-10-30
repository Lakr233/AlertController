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
                controller.present(alert, animated: true)
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
                controller.present(alert, animated: true)
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
                controller.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ Input", ephemeralAnnotation: .action { controller in
                let alert = AlertInputViewController(
                    title: "Hello World",
                    message: "You are going to input a text.",
                    placeholder: "sth...",
                    text: ""
                ) { text in print(text) }
                controller.present(alert, animated: true)
            }),
            .init(icon: "circle", title: "Open Alert w/ Progress", ephemeralAnnotation: .action { controller in
                let alert = AlertProgressIndicatorViewController(
                    title: "Hello World",
                    message: "This is a message from alert."
                )
                controller.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alert.dismiss(animated: true)
                }
            }),
            .init(icon: "circle", title: "OOB Description", ephemeralAnnotation: .action { controller in
                let alert = AlertProgressIndicatorViewController(
                    title: "Hello World",
                    message: """
                    Magna dolor anim Lorem ullamco. Magna nostrud voluptate occaecat proident officia aliqua est minim aliquip qui ad est mollit dolor. Eu elit incididunt elit tempor sunt fugiat laborum ex eiusmod minim eu ex consectetur. Sit laboris labore aute Lorem.

                    Irure id non ex cupidatat amet voluptate proident do duis anim proident qui nostrud. Pariatur aliqua quis ad adipisicing aute Lorem et magna consectetur. Cillum eiusmod quis tempor et ad commodo officia enim sit exercitation aute anim Lorem. Aute ea quis eiusmod consequat est proident dolor nisi. Magna voluptate adipisicing fugiat aute elit eu ullamco cillum.

                    Sunt occaecat dolore aliquip sit Lorem ea elit eiusmod incididunt consectetur sint minim consequat commodo. Consequat minim ullamco eu voluptate. Incididunt esse aliqua sit eu laborum elit anim pariatur laboris dolor minim. Laborum qui irure tempor cillum amet tempor excepteur nostrud ipsum proident proident. Veniam sint velit qui. Ut velit elit in ipsum reprehenderit voluptate irure sunt sit ipsum.

                    Esse ad ex veniam mollit ipsum aute fugiat. Aliquip irure deserunt in aute proident et. Aliqua laboris culpa qui officia ea eu sit excepteur occaecat dolore adipisicing aliqua. Occaecat eu exercitation proident deserunt pariatur proident veniam. Eu cillum in culpa quis Lorem occaecat eiusmod.

                    Ea qui nulla qui aliqua consectetur deserunt sit amet ipsum nisi id exercitation incididunt. Labore incididunt in id eiusmod ad. Fugiat qui non voluptate incididunt. Aliqua deserunt occaecat et elit velit occaecat labore eu eu adipisicing ea. Consequat adipisicing enim minim excepteur qui aute id minim cillum. Incididunt aliqua ullamco voluptate. Adipisicing anim veniam cillum occaecat exercitation reprehenderit.

                    Quis excepteur velit deserunt labore. Magna pariatur proident amet sint incididunt sunt ad. Nostrud aliquip nisi non commodo et officia ex elit qui minim commodo quis ut id nulla. Qui nulla dolore Lorem velit officia magna mollit velit deserunt sit id qui excepteur.

                    Aliquip reprehenderit irure voluptate cupidatat sit nulla. Cupidatat duis cillum qui consequat ex deserunt anim nostrud esse reprehenderit enim duis proident. Amet fugiat nostrud non enim fugiat in reprehenderit aliqua mollit duis elit dolore fugiat. Cupidatat magna consequat reprehenderit sint aliqua qui consectetur quis nisi non nisi. Minim do pariatur et fugiat consectetur dolore qui cillum irure veniam.

                    Incididunt irure commodo veniam et exercitation non. Deserunt exercitation nostrud quis est mollit ea ex excepteur labore. Officia mollit dolor irure dolore aliquip Lorem aliquip. Nisi magna est consectetur sit mollit tempor adipisicing duis non anim excepteur aliquip dolor consectetur eu. Aute reprehenderit exercitation est qui ut ex sit ad do sint laborum do. Duis pariatur eu elit minim commodo. Commodo fugiat enim adipisicing sunt elit pariatur commodo aliquip irure sit nisi magna est amet voluptate.

                    Non minim fugiat aute. Consequat enim excepteur voluptate excepteur dolor mollit. Fugiat eu proident nostrud aliquip veniam sit velit officia anim minim ad est duis labore. Aliquip duis fugiat velit dolore esse elit commodo deserunt aliqua magna amet cillum officia aute magna. Id anim magna veniam sunt culpa et excepteur sunt pariatur. Amet ex magna consectetur reprehenderit tempor aliqua laborum ea magna incididunt eu eu consectetur nulla adipisicing.
                    """
                )
                controller.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alert.dismiss(animated: true)
                }
            }),
        ]))
        present(panel, animated: true)
    }
}
