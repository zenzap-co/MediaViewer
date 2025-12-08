import UIKit

@MainActor
protocol PageViewControllerUIDelegate: AnyObject {
    func dismissActionTriggered()
    func presentActivityActionTriggered()
}

final class PageViewController: UIPageViewController {
    weak var uiDelegate: (any PageViewControllerUIDelegate)? = nil
    
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
}
