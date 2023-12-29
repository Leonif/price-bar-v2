//
//  BaseViewController.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import UIKit
import SwiftUI
import Combine

class BaseViewController<ViewModel, View: UIView>: UIViewController {
    
    let viewModel: ViewModel
    let rootView: View
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.rootView = View()
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    func setup() {}
    
}

class BaseHostingController<A: View>: UIHostingController<A> {
    
    var isSwipeToBackEnabled: Bool = false {
        didSet { navigationController?.interactivePopGestureRecognizer?.isEnabled = isSwipeToBackEnabled }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackBarButtonItem()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        isSwipeToBackEnabled = true
    }
    
    func setupBackBarButtonItem() {
        // hide in view - use code .navigationBarBackButtonHidden(true)
        if let navigationController = navigationController, navigationController.viewControllers.first != self {
        }
    }
    
    func setupBindings() {
    }

    func setupUI() {
    }
}
