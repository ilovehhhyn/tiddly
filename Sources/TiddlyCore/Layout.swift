import Foundation

public struct Size: Equatable { public var width: Double; public var height: Double; public init(width: Double, height: Double) { self.width = width; self.height = height } }
public struct Point: Equatable { public var x: Double; public var y: Double; public init(x: Double, y: Double) { self.x = x; self.y = y } }
/// A rectangle in top-left screen coordinates (y grows downward), the convention the saved position uses.
public struct Rect: Equatable {
  public var x: Double; public var y: Double; public var width: Double; public var height: Double
  public init(x: Double, y: Double, width: Double, height: Double) { self.x = x; self.y = y; self.width = width; self.height = height }
}

public enum Layout {
  public static let petWindow = Size(width: 176, height: 176)
  public static let panelWindow = Size(width: 220, height: 410)

  /// Bottom-right corner of the work area with a 24 point margin.
  public static func defaultPosition(workArea: Rect, size: Size) -> Point {
    Point(x: workArea.x + workArea.width - size.width - 24, y: workArea.y + workArea.height - size.height - 24)
  }

  /// The panel window shares the pet window's bottom-right corner, clamped inside the work area.
  public static func panelOrigin(petOrigin: Point, workArea: Rect) -> Point {
    let desiredX = petOrigin.x + petWindow.width - panelWindow.width
    let desiredY = petOrigin.y + petWindow.height - panelWindow.height
    return Point(x: max(workArea.x, min(desiredX, workArea.x + workArea.width - panelWindow.width)),
                 y: max(workArea.y, min(desiredY, workArea.y + workArea.height - panelWindow.height)))
  }
}

/// Graph geometry in the original 300 × 120 view box.
public enum Graph {
  public struct Geometry: Equatable { public let curve: [Point]; public let marker: Point; public let referenceY: Double }

  public static func geometry(markerX: Double) -> Geometry {
    let maxX = max(0.16, ceil(markerX / 0.08) * 0.08)
    let maxY = Progression.curveY(maxX)
    func point(_ x: Double) -> Point { Point(x: 10 + 280 * x / maxX, y: 100 - 85 * Progression.curveY(x) / maxY) }
    let curve = (0...40).map { point(maxX * Double($0) / 40) }
    return Geometry(curve: curve, marker: point(markerX), referenceY: point(Progression.referenceX).y)
  }
}
