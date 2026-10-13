// Rendert het app-icoon (spiegelbol boven een dansvloer) naar een PNG.
// Gebruik: sh build.sh (maakt het icoon als AppIcon.icns nog niet bestaat)
import Cocoa

let S = 1024.0
let cs = CGColorSpaceCreateDeviceRGB()
let g = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
func rgb(_ r: Double, _ gr: Double, _ b: Double, _ a: Double = 1) -> CGColor { CGColor(red: r, green: gr, blue: b, alpha: a) }
let neon: [(Double, Double, Double)] = [(1, 0.18, 0.58), (0, 0.9, 1), (1, 0.9, 0), (0.49, 1, 0), (0.73, 0.4, 1), (1, 0.42, 0)]

// macOS-icoonvorm
g.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 185, cornerHeight: 185, transform: nil))
g.clip()
g.setFillColor(rgb(0.04, 0.02, 0.09))
g.fill(CGRect(x: 0, y: 0, width: S, height: S))

// dansvloer in perspectief: rijen tegels die naar achteren smaller worden
for row in 0..<5 {
    let y0 = 100 + Double(row) * 52 * (1 - Double(row) * 0.09), h = 50 * (1 - Double(row) * 0.1)
    let inset = Double(row) * 70
    let w = (824 - 2 * inset) / 6
    for col in 0..<6 {
        let c = neon[(row * 5 + col * 2) % 6], on = (row + col) % 2 == 0
        g.setFillColor(rgb(c.0, c.1, c.2, on ? 0.95 : 0.22))
        g.fill(CGRect(x: 100 + inset + Double(col) * w + 3, y: y0, width: w - 6, height: h))
    }
}

// lichtbundels vanaf de bol
for (i, a) in [-0.9, -0.35, 0.3, 0.85].enumerated() {
    let c = neon[i + 1]
    g.setFillColor(rgb(c.0, c.1, c.2, 0.16))
    g.move(to: CGPoint(x: 512, y: 610))
    g.addLine(to: CGPoint(x: 512 + sin(a - 0.13) * 700, y: 610 - cos(a - 0.13) * 700))
    g.addLine(to: CGPoint(x: 512 + sin(a + 0.13) * 700, y: 610 - cos(a + 0.13) * 700))
    g.closePath()
    g.fillPath()
}

// spiegelbol: ringen van spiegeltjes, lichter naar linksboven
let cx = 512.0, cy = 610.0, R = 215.0
g.setFillColor(rgb(0.02, 0.02, 0.04))
g.fillEllipse(in: CGRect(x: cx - R, y: cy - R, width: 2 * R, height: 2 * R))
let rings = 13
for r in 0..<rings {
    let p0 = -Double.pi / 2 + Double.pi * Double(r) / Double(rings), p1 = p0 + Double.pi / Double(rings), pm = (p0 + p1) / 2
    let n = max(3, Int((Double(rings) * 2 * cos(pm)).rounded()))
    for k in 0..<n {
        let a0 = Double.pi * Double(k) / Double(n) - Double.pi / 2, a1 = Double.pi * Double(k + 1) / Double(n) - Double.pi / 2, am = (a0 + a1) / 2
        func pt(_ p: Double, _ a: Double) -> CGPoint { CGPoint(x: cx + R * cos(p) * sin(a), y: cy + R * sin(p)) }
        let light = max(0, cos(pm - 0.6) * cos(am + 0.5))
        let c = neon[(r * 3 + k * 5) % 6], tint = (r * 7 + k * 3) % 4 == 0 ? 0.55 : 0.12
        let v = 0.16 + 0.84 * pow(light, 1.5)
        g.setFillColor(rgb(v * (1 - tint) + c.0 * tint * (0.4 + v), v * (1 - tint) + c.1 * tint * (0.4 + v), v * (1 - tint) + c.2 * tint * (0.4 + v)))
        let q = [pt(p0, a0), pt(p0, a1), pt(p1, a1), pt(p1, a0)]
        let m = CGPoint(x: (q[0].x + q[2].x) / 2, y: (q[0].y + q[2].y) / 2)
        g.move(to: CGPoint(x: m.x + (q[0].x - m.x) * 0.88, y: m.y + (q[0].y - m.y) * 0.88))
        for i in 1..<4 { g.addLine(to: CGPoint(x: m.x + (q[i].x - m.x) * 0.88, y: m.y + (q[i].y - m.y) * 0.88)) }
        g.closePath()
        g.fillPath()
    }
}
// ophangdraad en een paar schitteringen
g.setFillColor(rgb(0.5, 0.5, 0.55))
g.fill(CGRect(x: cx - 4, y: cy + R, width: 8, height: 120))
for (x, y, s) in [(430.0, 700.0, 26.0), (585.0, 655.0, 16.0), (470.0, 560.0, 12.0)] {
    g.setFillColor(rgb(1, 1, 1, 0.95))
    g.move(to: CGPoint(x: x - s, y: y)); g.addLine(to: CGPoint(x: x, y: y + s * 0.18)); g.addLine(to: CGPoint(x: x + s, y: y)); g.addLine(to: CGPoint(x: x, y: y - s * 0.18)); g.closePath(); g.fillPath()
    g.move(to: CGPoint(x: x, y: y - s)); g.addLine(to: CGPoint(x: x + s * 0.18, y: y)); g.addLine(to: CGPoint(x: x, y: y + s)); g.addLine(to: CGPoint(x: x - s * 0.18, y: y)); g.closePath(); g.fillPath()
}

let png = NSBitmapImageRep(cgImage: g.makeImage()!).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
