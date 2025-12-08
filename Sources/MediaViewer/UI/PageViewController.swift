import UIKit
import AVFoundation

@MainActor
protocol PageViewControllerUIDelegate: AnyObject {
    func dismissActionTriggered()
    func presentActivityActionTriggered() async
}

@MainActor
final class PageViewController: UIPageViewController {
    
    weak var uiDelegate: PageViewControllerUIDelegate? = nil
        
    private lazy var itemBottomStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            primaryAction: UIAction { [weak self] _ in
                self?.uiDelegate?.dismissActionTriggered()
            }
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
            Task {
                await self?.uiDelegate?.presentActivityActionTriggered()
            }
        })
    }
    
    override var keyCommands: [UIKeyCommand]? {
        [
            {
                let command = UIKeyCommand(
                    input: UIKeyCommand.inputLeftArrow,
                    modifierFlags: [],
                    action: #selector(backward)
                )
                command.wantsPriorityOverSystemBehavior = true
                return command
            }(),
            {
                let command = UIKeyCommand(
                    input: UIKeyCommand.inputRightArrow,
                    modifierFlags: [],
                    action: #selector(forward)
                )
                command.wantsPriorityOverSystemBehavior = true
                return command
            }()
        ]
    }
    
    @objc func backward() {
        guard let currentViewController = viewControllers?.first else {
            return
        }
        let beforeViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController)
        if let beforeViewController {
            setViewControllers(
                [beforeViewController],
                direction: .reverse,
                animated: true,
                completion: nil
            )
        }
    }
    
    @objc func forward() {
        guard let currentViewController = viewControllers?.first else {
            return
        }
        let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
        if let nextViewController {
            setViewControllers(
                [nextViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemBottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemBottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemBottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

@MainActor
private extension UIStackView {
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        return arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }

    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}
