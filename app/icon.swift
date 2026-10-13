// Rendert het app-icoon (Julia-set in macOS-icoonvorm) naar icon.png.
// Gebruik: sh make-icon.sh
import Cocoa

let S = 1024
var px = [UInt8](repeating: 0, count: S * S * 4)
func smooth(_ a: Double, _ b: Double, _ x: Double) -> Double {
    let t = min(1, max(0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)
}
for y in 0..<S {
    for x in 0..<S {
        var zx = (Double(x) / Double(S) * 2 - 1) * 1.9
        var zy = (Double(y) / Double(S) * 2 - 1) * 1.9
        var i = 0.0
        while i < 220 && zx * zx + zy * zy < 64 {
            (zx, zy) = (zx * zx - zy * zy - 0.8, 2 * zx * zy + 0.156)
            i += 1
        }
        var rgb = [0.02, 0.0, 0.05]
        if i < 220 {
            let sm = i - log2(log2(zx * zx + zy * zy)) + 2
            let t = sm * 0.03 + 0.55
            let br = 0.1 + 0.9 * smooth(0, 14, sm)
            let offs: [Double] = [0.0, 0.33, 0.67]
            for k in 0..<3 {
                let c: Double = cos(2.0 * Double.pi * (t + offs[k]))
                rgb[k] = (0.5 + 0.5 * c) * br
            }
        }
        let o = (y * S + x) * 4
        for k in 0..<3 { px[o + k] = UInt8(min(255, max(0, pow(rgb[k], 0.85) * 255))) }
        px[o + 3] = 255
    }
}

let cs = CGColorSpaceCreateDeviceRGB()
let img = px.withUnsafeMutableBytes { buf in
    CGContext(data: buf.baseAddress, width: S, height: S, bitsPerComponent: 8, bytesPerRow: S * 4, space: cs,
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
}
// macOS-icoonvorm: afgeronde rechthoek van 824 px in een canvas van 1024 px
let out = CGContext(data: nil, width: S, height: S, bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
out.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 185, cornerHeight: 185, transform: nil))
out.clip()
out.draw(img, in: CGRect(x: 0, y: 0, width: S, height: S))
let png = NSBitmapImageRep(cgImage: out.makeImage()!).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
