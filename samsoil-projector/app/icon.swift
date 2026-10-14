// Rendert het app-icoon (gemarmerde vloeistof met oliedruppels in de macOS-icoonvorm) naar een PNG.
// Gebruik: sh build.sh (maakt het icoon als AppIcon.icns nog niet bestaat)
import Cocoa

let S = 1024
var px = [UInt8](repeating: 0, count: S * S * 4)
let inks: [[Double]] = [[0.95, 0.12, 0.05], [1, 0.5, 0.05], [1, 0.9, 0.2], [0.45, 0.2, 0.95]]
for y in 0..<S {
    for x in 0..<S {
        let u = Double(x) / Double(S) * 2 - 1, v = Double(y) / Double(S) * 2 - 1
        // gemarmerde banden: een paar keer door elkaar gevouwen sinussen
        var wx = u, wy = v
        for k in 0..<3 {
            let f = 1.6 + Double(k) * 0.9
            (wx, wy) = (wx + 0.35 * sin(wy * f * 2.1 + Double(k)), wy + 0.35 * sin(wx * f * 1.7 + Double(k) * 2.0))
        }
        let t = wy * 2.4 + 0.6 * sin(wx * 3.0)
        let band = (sin(t * 3.14159) * 0.5 + 0.5)
        let idx = Int(floor(t * 1.5)) & 3, nxt = (idx + 1) & 3
        var rgb = [0.0, 0.0, 0.0]
        for c in 0..<3 { rgb[c] = inks[idx][c] * (1 - band * 0.6) + inks[nxt][c] * band * 0.6 }
        let glow = pow(max(0, sin(t * 3.14159 * 0.5)), 12)  // dunne felle lijnen waar weinig verf zit
        for c in 0..<3 { rgb[c] = min(1, rgb[c] * 0.9 + glow * 0.5) }
        let o = (y * S + x) * 4
        for c in 0..<3 { px[o + c] = UInt8(max(0, min(255, pow(rgb[c], 0.9) * 255))) }
        px[o + 3] = 255
    }
}
let cs = CGColorSpaceCreateDeviceRGB()
let img = px.withUnsafeMutableBytes { buf in
    CGContext(data: buf.baseAddress, width: S, height: S, bitsPerComponent: 8, bytesPerRow: S * 4, space: cs,
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
}
let g = CGContext(data: nil, width: S, height: S, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
g.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 185, cornerHeight: 185, transform: nil))
g.clip()
g.draw(img, in: CGRect(x: 0, y: 0, width: S, height: S))
// oliedruppels: donkere ronde puntjes met een lichtpuntje, en één grote bel
srand48(7)
for i in 0..<34 {
    let r = i == 0 ? 120.0 : pow(drand48(), 2.5) * 34 + 7
    let cx = i == 0 ? 640.0 : 150 + drand48() * 724, cy = i == 0 ? 600.0 : 150 + drand48() * 724
    let rect = CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r)
    if i == 0 {
        g.setFillColor(CGColor(red: 1, green: 0.95, blue: 0.8, alpha: 0.18)); g.fillEllipse(in: rect)
        g.setStrokeColor(CGColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 0.6)); g.setLineWidth(8); g.strokeEllipse(in: rect.insetBy(dx: 4, dy: 4))
    } else {
        g.setFillColor(CGColor(red: 0.06, green: 0.04, blue: 0.1, alpha: 0.85)); g.fillEllipse(in: rect)
    }
    g.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.7))
    g.fillEllipse(in: CGRect(x: cx - r * 0.45, y: cy + r * 0.2, width: r * 0.35, height: r * 0.35))
}
let png = NSBitmapImageRep(cgImage: g.makeImage()!).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
