import UIKit

@MainActor
final class DismissAnimator: Animator {
    override func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        let previewController = transitionContext.viewController(forKey: .from) as! PreviewController
        let container = transitionContext.containerView
        
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: 0.82
        )
        
        guard let fromTransitionView = container.viewWithTag(PresentationConsts.transitionViewTag),
              let toControllerView = transitionContext.viewController(forKey: .to)?.view,
              let fromControllerView = transitionContext.viewController(forKey: .from)?.view,
              let toTransitionView = previewController.currentTransitionView,
              let topView = previewController.topView else {
            
            previewController.currentTransitionView?.isHidden = false
            
            animator.addAnimations {
                transitionContext.containerView.backgroundColor = .clear
                previewController.topView?.alpha = 0.0
            }
            
            animator.addCompletion { _ in
                let didComplete = !transitionContext.transitionWasCancelled
                if !didComplete {
                    previewController.internalNavigationController.navigationBar.alpha = 1.0
                    previewController.topView?.alpha = 1.0
                }
                transitionContext.completeTransition(didComplete)
            }
            return animator
        }
                
        let targetFrame = toTransitionView.convert(toTransitionView.bounds, to: container)
        
        animator.addAnimations {
            toControllerView.alpha = 1.0
        }
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
                    fromTransitionView.frame = targetFrame
                }
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.1) {
                    toTransitionView.alpha = 1.0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.1) {
                    fromTransitionView.alpha = 0.0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    fromControllerView.alpha = 0.0
                }
            })
        }

        animator.addCompletion { _ in
            fromTransitionView.removeFromSuperview()
            let didComplete = !transitionContext.transitionWasCancelled
            if !didComplete {
                previewController.internalNavigationController.navigationBar.alpha = 1.0
                previewController.topView?.alpha = 1.0
            }
            transitionContext.completeTransition(didComplete)
        }
        
        return animator
    }
}
