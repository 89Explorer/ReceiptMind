//
//  SceneDelegate.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/28/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        //let vc = UINavigationController(rootViewController: ViewController())
        let vc = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
    }

}

