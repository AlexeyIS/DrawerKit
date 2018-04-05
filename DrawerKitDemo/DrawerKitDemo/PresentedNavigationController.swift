import UIKit
import DrawerKit

class PresentedNavigationController: UINavigationController {}

extension PresentedNavigationController: DrawerAnimationParticipant {
    var drawerAnimationActions: DrawerAnimationActions {
        return (topViewController as? DrawerAnimationParticipant)?.drawerAnimationActions
            ?? DrawerAnimationActions()
    }
}

extension PresentedNavigationController: DrawerPresentable {
    var heightOfPartiallyExpandedDrawer: CGFloat {
        return (topViewController as? DrawerPresentable)?.heightOfPartiallyExpandedDrawer ?? 0.0
    }

    var scrollViewForPullToDismiss: UIScrollView? {
        return (topViewController as? DrawerPresentable)?.scrollViewForPullToDismiss
    }
}
