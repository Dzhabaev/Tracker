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
    
    private lazy var pages: [UIViewController] = {
        let blue = UIViewController()
        let blueImageView = UIImageView(image: UIImage(named: "blueOnboarding"))
        blueImageView.contentMode = .scaleAspectFill
        blueImageView.translatesAutoresizingMaskIntoConstraints = false
        blue.view.addSubview(blueImageView)
        NSLayoutConstraint.activate([
            blueImageView.leadingAnchor.constraint(equalTo: blue.view.leadingAnchor),
            blueImageView.trailingAnchor.constraint(equalTo: blue.view.trailingAnchor),
            blueImageView.topAnchor.constraint(equalTo: blue.view.topAnchor),
            blueImageView.bottomAnchor.constraint(equalTo: blue.view.bottomAnchor)
        ])
        
        let blueTextLabel = UILabel()
        blueTextLabel.translatesAutoresizingMaskIntoConstraints = false
        blueTextLabel.text = "Отслеживайте только то, что хотите"
        blueTextLabel.numberOfLines = 3
        blueTextLabel.textColor = .trBlackAny
        blueTextLabel.textAlignment = .center
        blueTextLabel.font = .systemFont(ofSize: 32, weight: .bold)
        blue.view.addSubview(blueTextLabel)
        NSLayoutConstraint.activate([
            blueTextLabel.leadingAnchor.constraint(equalTo: blue.view.leadingAnchor, constant: 16),
            blueTextLabel.trailingAnchor.constraint(equalTo: blue.view.trailingAnchor, constant: -16),
            blueTextLabel.topAnchor.constraint(equalTo: blue.view.centerYAnchor)
        ])
        
        let red = UIViewController()
        let redImageView = UIImageView(image: UIImage(named: "redOnboarding"))
        redImageView.contentMode = .scaleAspectFill
        redImageView.translatesAutoresizingMaskIntoConstraints = false
        red.view.addSubview(redImageView)
        NSLayoutConstraint.activate([
            redImageView.leadingAnchor.constraint(equalTo: red.view.leadingAnchor),
            redImageView.trailingAnchor.constraint(equalTo: red.view.trailingAnchor),
            redImageView.topAnchor.constraint(equalTo: red.view.topAnchor),
            redImageView.bottomAnchor.constraint(equalTo: red.view.bottomAnchor)
        ])
        
        let redTextLabel = UILabel()
        redTextLabel.translatesAutoresizingMaskIntoConstraints = false
        redTextLabel.text = "Даже если это\nне литры воды и йога"
        redTextLabel.numberOfLines = 3
        redTextLabel.textColor = .trBlackAny
        redTextLabel.textAlignment = .center
        redTextLabel.font = .systemFont(ofSize: 32, weight: .bold)
        red.view.addSubview(redTextLabel)
        NSLayoutConstraint.activate([
            redTextLabel.leadingAnchor.constraint(equalTo: red.view.leadingAnchor, constant: 16),
            redTextLabel.trailingAnchor.constraint(equalTo: red.view.trailingAnchor, constant: -16),
            redTextLabel.topAnchor.constraint(equalTo: red.view.centerYAnchor)
        ])
        
        return [blue, red]
    }()
    
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
        button.setTitle("Вот это технологии!", for: .normal)
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
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
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
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
