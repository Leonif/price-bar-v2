//
//  SceneDelegate.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let navigationController = UINavigationController()
    private lazy var coordinator = MainCoordinator(navigationController: navigationController, modelContext: createModelContext())

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        coordinator.start()
        self.window = window
    }
    
    @MainActor
    private func createModelContext() -> ModelContext  {
        return try! ModelContainer(for: Product.self, Pricing.self, History.self).mainContext
    }
}

