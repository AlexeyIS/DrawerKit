import UIKit

/// A protocol that view controllers presented inside a drawer must conform to.

public protocol DrawerPresentable: class {
    /// The height at which the drawer must be presented when it's in its
    /// partially expanded state. If negative, its value is clamped to zero.
    var heightOfPartiallyExpandedDrawer: CGFloat { get }

    /// The scroll view to enable pull-to-dismiss on the drawer. It can be
    /// placed at any origin of any arbitrary size.
    ///
    /// - important: The drawer materialises pull-to-dismiss by installing its
    ///              internal controller as the scroll view delegate, and
    ///              manipulating the vertical content offset.
    var scrollViewForPullToDismiss: UIScrollView? { get }
}

extension DrawerPresentable {
    public var scrollViewForPullToDismiss: UIScrollView? {
        return nil
    }
}
