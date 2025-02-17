import SwiftUI

struct CustomFont {
    static func regular(size: CGFloat) -> Font {
        .custom("Inter-Regular", size: size)
    }

    static func bold(size: CGFloat) -> Font {
        .custom("Inter-Bold", size: size)
    }

    static func medium(size: CGFloat) -> Font {
        .custom("Inter-Medium", size: size)
    }

    static func semiBold(size: CGFloat) -> Font {
        .custom("Inter-SemiBold", size: size)
    }
    
    static func extraLight(size: CGFloat) -> Font {
        .custom("Inter-ExtraLight", size: size)
    }
    
    static func light(size: CGFloat) -> Font {
        .custom("Inter-Light", size: size)
    }
}
