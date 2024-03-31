//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Chingiz on 31.01.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    var onboardingCompletionHandler: (() -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var pages: [OnboardingPageViewController] = [
        OnboardingPageViewController(imageName: "blueOnboarding", labelText: NSLocalizedString("onboardingBlueLabelText.title", comment: "")),
        OnboardingPageViewController(imageName: "redOnboarding", labelText: NSLocalizedString("onboardingRedLabelText.title", comment: ""))
    ]
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPageIndicatorTintColor = .trBlackAny
        control.pageIndicatorTintColor = .trBlackAny.withAlphaComponent(0.3)
        control.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        return control
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .trBlackAny
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("onboardingDoneButton.setTitle", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UIPageViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSourceAndDelegate()
        setupUI()
        setupInitialViewController()
    }
    
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: navigationOrientation,
            options: options
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func pushButton() {
        onboardingCompletionHandler?()
    }
    
    @objc private func pageControlDidChange() {
        let currentPage = pageControl.currentPage
        if currentPage < pages.count {
            setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func configureDataSourceAndDelegate() {
        dataSource = self
        delegate = self
    }
    
    private func setupInitialViewController() {
        guard let firstViewController = pages.first else {
            return
        }
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first as? OnboardingPageViewController,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
