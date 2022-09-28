//
//  TaskBlockPath.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/09/28.
//

import SwiftUI

struct TaskBlockPath: Shape {
    
    let radius: CGFloat
    var top: CGFloat
    var bottom: CGFloat
    var leading: CGFloat
    var traling: CGFloat

    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let a = CGPoint(x: leading + radius, y: top)
        let b = CGPoint(x: traling - radius, y: top)
        let c = CGPoint(x: traling - radius, y: top + radius)
        let d = CGPoint(x: traling, y: bottom - radius)
        let e = CGPoint(x: traling - radius, y: bottom - radius)
        let f = CGPoint(x: leading + radius, y: bottom)
        let g = CGPoint(x: leading + radius, y: bottom - radius)
        let h = CGPoint(x: leading, y: top + radius)
        let i = CGPoint(x: leading + radius, y: top + radius)

        path.move(to: a)
        path.addLine(to: b)
        path.addRelativeArc(center: c, radius: radius,
          startAngle: Angle.degrees(180), delta: Angle.degrees(180))
        path.addLine(to: d)
        path.addRelativeArc(center: e, radius: radius,
          startAngle: Angle.degrees(270), delta: Angle.degrees(180))
        path.addLine(to: f)
        path.addRelativeArc(center: g, radius: radius,
          startAngle: Angle.degrees(90), delta: Angle.degrees(90))
        path.addLine(to: h)
        path.addRelativeArc(center: i, radius: radius,
          startAngle: Angle.degrees(180), delta: Angle.degrees(270))
        
        return path
    }
}

