//
//  TabBarController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Combine
import SwiftUI

class TabBarController: UITabBarController {
    
    private var loginViewController: UIHostingController<NintendoAccountLoginPage>?
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var onboardingCancellable: AnyCancellable?
    
    private var tabBarViewModel = TabBarViewModel()
    private var synchronizeBattleViewModel = SynchronizeBattleViewModel()
    private var synchronizeJobViewModel = SynchronizeJobViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
        
        tabBarViewModel.$isLogined
            .assign(to: &synchronizeBattleViewModel.$isLogined)
        
        tabBarViewModel.$isLogined
            .assign(to: &synchronizeJobViewModel.$isLogined)
        
        NotificationCenter.default
            .publisher(for: .logout)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: &tabBarViewModel.$isLogined)
        
        NotificationCenter.default
            .publisher(for: .showLoginView)
            .sink { [weak self] _ in
                self?.showLogin()
            }
            .store(in: &cancelBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarViewModel.$isLogined
            .removeDuplicates()
            .sink { [weak self] logined in
                self?.setupItems(isLogined: logined)
            }
            .store(in: &cancelBag)
        
        if AppUserDefaults.shared.firstLaunch {
            showOnboarding()
        }
    }
    
    func setupItems(isLogined: Bool) {
        
        let homeViewController = UIHostingController(rootView: HomePage(isLogined: isLogined))
        homeViewController.tabBarItem.title = NSLocalizedString("Home", comment: "")
        homeViewController.tabBarItem.image = UIImage(named: "TabBarHome")
        
        let jobListViewController = UIHostingController(rootView: JobListPage(isLogined: isLogined))
        jobListViewController.tabBarItem.title = NSLocalizedString("Salmon Run", comment: "")
        jobListViewController.tabBarItem.image = UIImage(named: "TabBarSalmonRun")
        
        let battleListViewController = UIHostingController(rootView: BattleListPage(isLogined: isLogined))
        battleListViewController.tabBarItem.title = NSLocalizedString("Battles", comment: "")
        battleListViewController.tabBarItem.image = UIImage(named: "TabBarBattle")
        
        let meViewController = UIHostingController(rootView: MePage(isLogined: isLogined))
        meViewController.tabBarItem.title = NSLocalizedString("Me", comment: "")
        meViewController.tabBarItem.image = UIImage(named: "TabBarMe")
        
        viewControllers = [homeViewController, battleListViewController, jobListViewController, meViewController]
    }
    
    func showLogin() {
        let viewModel = LoginViewModel()

        let loginPage = NintendoAccountLoginPage(viewModel: viewModel)
        let loginViewController = UIHostingController(rootView: loginPage)
        loginViewController.modalPresentationStyle = .formSheet
        
        viewModel.$status
            .filter { $0 == .loginSuccess }
            .sink { [weak self] _ in
                self?.tabBarViewModel.isLogined = true
                self?.loginViewController?.presentingViewController?.dismiss(animated: true)
            }
            .store(in: &viewModel.cancelBag)
        
        self.loginViewController = loginViewController
        
        present(loginViewController, animated: true)
    }
    
    func showOnboarding() {
        let viewModel = OnboardingViewModel()
        
        let onboardingPage = OnboardingPage(viewModel: viewModel)
        let onboardingViewController = UIHostingController(rootView: onboardingPage)
        onboardingViewController.modalPresentationStyle = .formSheet
        onboardingViewController.isModalInPresentation = true
        onboardingViewController.preferredContentSize = .init(width: 624, height: 800)
        
        onboardingCancellable?.cancel()
        onboardingCancellable = viewModel.$dismiss
            .sink { dismiss in
                if dismiss {
                    onboardingViewController.dismiss(animated: true, completion: nil)
                    AppUserDefaults.shared.firstLaunch = false
                }
            }

        present(onboardingViewController, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
}
