import SwiftUI
import UIKit

extension Color {
    init?(hex: String) {
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int), hex.count == 8 else { return nil }
        let r = Double((int >> 24) & 0xFF) / 255
        let g = Double((int >> 16) & 0xFF) / 255
        let b = Double((int >> 8)  & 0xFF) / 255
        let a = Double( int        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    var hexString: String {
        let c = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = c[0], g = c[1], b = c[2], a = c.count > 3 ? c[3] : 1
        return String(format: "%02X%02X%02X%02X",
            Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int), hex.count == 8 else { return nil }
        let r = CGFloat((int >> 24) & 0xFF) / 255
        let g = CGFloat((int >> 16) & 0xFF) / 255
        let b = CGFloat((int >> 8)  & 0xFF) / 255
        let a = CGFloat( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
