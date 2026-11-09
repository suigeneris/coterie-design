import Testing
import SwiftUI
import UIKit
@testable import OursDesignSystem

@MainActor
func renderedHeight<V: View>(of view: V, width: CGFloat = 200, scale: CGFloat = 1) -> CGFloat {
    let renderer = ImageRenderer(content: view.frame(width: width))
    renderer.scale = scale
    return renderer.uiImage?.size.height ?? 0
}

struct RenderedPixels: CustomStringConvertible {
    let scale: CGFloat
    let pointWidth: CGFloat
    let pointHeight: CGFloat
    private let pixelWidth: Int
    private let pixelHeight: Int
    private let data: [UInt8]

    var description: String { "\(pointWidth)x\(pointHeight)pt rendering" }

    @MainActor
    init?<V: View>(_ view: V, scale: CGFloat = 3) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        guard let image = renderer.uiImage?.cgImage,
              let context = CGContext(
                data: nil,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ),
              let buffer = context.data
        else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        self.scale = scale
        pixelWidth = image.width
        pixelHeight = image.height
        pointWidth = CGFloat(image.width) / scale
        pointHeight = CGFloat(image.height) / scale
        data = Array(UnsafeBufferPointer(start: buffer.assumingMemoryBound(to: UInt8.self), count: image.width * image.height * 4))
    }

    func isOpaque(x pointX: CGFloat, y pointY: CGFloat) -> Bool {
        guard let pixel = pixel(x: pointX, y: pointY) else { return false }
        return pixel.alpha > 0.99
    }

    func isColor(_ color: Color, x pointX: CGFloat, y pointY: CGFloat, tolerance: Double = 0.02) -> Bool {
        guard let pixel = pixel(x: pointX, y: pointY), pixel.alpha > 0.99 else { return false }
        return pixel.matches(color, tolerance: tolerance)
    }

    func contains(_ color: Color, tolerance: Double = 0.02) -> Bool {
        for row in 0..<pixelHeight {
            for column in 0..<pixelWidth {
                let pixel = pixelAt(column: column, row: row)
                if pixel.alpha > 0.99 && pixel.matches(color, tolerance: tolerance) { return true }
            }
        }
        return false
    }

    func horizontalExtent(of color: Color, tolerance: Double = 0.02) -> CGFloat {
        var leftmost = pixelWidth
        var rightmost = -1
        for row in 0..<pixelHeight {
            for column in 0..<pixelWidth {
                let pixel = pixelAt(column: column, row: row)
                if pixel.alpha > 0.99 && pixel.matches(color, tolerance: tolerance) {
                    leftmost = min(leftmost, column)
                    rightmost = max(rightmost, column)
                }
            }
        }
        return rightmost < leftmost ? 0 : CGFloat(rightmost - leftmost + 1) / scale
    }

    private func pixel(x pointX: CGFloat, y pointY: CGFloat) -> Pixel? {
        let column = Int(pointX * scale)
        let row = Int(pointY * scale)
        guard column >= 0, column < pixelWidth, row >= 0, row < pixelHeight else { return nil }
        return pixelAt(column: column, row: row)
    }

    private func pixelAt(column: Int, row: Int) -> Pixel {
        let offset = (row * pixelWidth + column) * 4
        return Pixel(
            red: Double(data[offset]) / 255,
            green: Double(data[offset + 1]) / 255,
            blue: Double(data[offset + 2]) / 255,
            alpha: Double(data[offset + 3]) / 255
        )
    }

    private struct Pixel {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        func matches(_ color: Color, tolerance: Double) -> Bool {
            var expectedRed: CGFloat = 0, expectedGreen: CGFloat = 0, expectedBlue: CGFloat = 0, expectedAlpha: CGFloat = 0
            UIColor(color)
                .resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                .getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha)
            return abs(red - Double(expectedRed)) <= tolerance
                && abs(green - Double(expectedGreen)) <= tolerance
                && abs(blue - Double(expectedBlue)) <= tolerance
        }
    }
}
