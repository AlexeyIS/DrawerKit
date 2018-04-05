extension PresentationController {
    var scrollViewForPullToDismiss: UIScrollView? {
        if let presentable = presentedViewController as? DrawerPresentable {
            return presentable.scrollViewForPullToDismiss
        }
        return nil
    }
}

extension PresentationController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollTranslationY = 0.0
        scrollEndVelocity = nil
        scrollWillEndDragging = false

        // Record the maximum top content inset that has even been observed.
        // This is necessary to support `UINavigationController` drawers with
        // Large Titles, since there is no any other way to query this
        // information.
        scrollMaxTopInset = max(scrollView.topInset, scrollMaxTopInset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isScrollEnabled,
              !scrollWillEndDragging,
              scrollEndVelocity == nil
            else { return }

        let topInset = scrollView.topInset
        let negativeVerticalOffset = -(scrollView.contentOffset.y + topInset)

        // Intercept the content offset changes beyond the top content inset.
        // The algorithm is aware of dynamic content inset adjustments induced
        // by the Navigation Bar Large Title Mode since iOS 11.0.
        if scrollTranslationY > 0.0 || (topInset == scrollMaxTopInset && negativeVerticalOffset > 0.0) {
            scrollTranslationY = max(scrollTranslationY + negativeVerticalOffset, 0.0)
            self.applyTranslationY(negativeVerticalOffset)
            scrollView.contentOffset.y = -topInset

            // Detect and animate any top content inset change due to its parent
            // `UINavigationController` (if any) moving away from (0, 0) in
            // screen coordinates.
            let delta = topInset - scrollView.topInset
            UIView.animate(withDuration: 0.1) {
                if delta > 0.0 {
                    self.scrollTranslationY += delta
                    self.applyTranslationY(delta)
                }
                self.presentedViewController.view.layoutIfNeeded()
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollEndVelocity = velocity
        scrollWillEndDragging = true

        if scrollTranslationY > 0.0 {
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let velocity = scrollEndVelocity,
              scrollTranslationY > 0.0 else { return }

        let drawerSpeedY = -velocity.y / containerViewHeight
        let endingState = GeometryEvaluator.nextStateFrom(currentState: currentDrawerState,
                                                          speedY: drawerSpeedY,
                                                          drawerPartialHeight: drawerPartialHeight,
                                                          containerViewHeight: containerViewHeight,
                                                          configuration: configuration)

        animateTransition(
            to: endingState,
            animateAlongside: {
                self.presentedViewController.view.layoutIfNeeded()
                scrollView.contentOffset.y = -scrollView.topInset
                scrollView.flashScrollIndicators()
            },
            completion: {
                self.scrollTranslationY = 0.0
                self.scrollEndVelocity = nil
            }
        )
    }
}

private extension UIScrollView {
    var topInset: CGFloat {
        if #available(iOS 11.0, *) {
            return adjustedContentInset.top
        } else {
            return contentInset.top
        }
    }
}
