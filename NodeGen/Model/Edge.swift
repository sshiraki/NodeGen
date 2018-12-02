//
//  Edge.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import CoreGraphics
import MapKit

// An Edge represents a road (one directional) from one node to another
struct Edge {
    let from:Int
    let to:Int
    let length:CLLocationDistance
    
    init(from:Int=0, to:Int=0, length:CLLocationDistance=0.0) {
        self.from = from
        self.to = to
        self.length = length
    }
    
    // For rendering
    func addPath(view:MKMapView, graph:Graph) {
        let locationFrom = graph.location(at: from)
        let locationTo = graph.location(at: to)
//        ctx.move(to: CGPoint(x: locationFrom.x * scale, y: locationFrom.y * scale))
//        ctx.addLine(to: CGPoint(x: locationTo.x * scale, y: locationTo.y * scale))
        Direction().addRoute(view: view, locationFrom: locationFrom, locationTo: locationTo)
    }

    var dictionary:[String:Any] {
        return [
            "from": self.from,
            "to": self.to,
            "length": self.length
        ];
    }
}

extension Edge: CustomStringConvertible {
    var description: String {
        return String(format: "%d->%d", from, to)
    }
}

extension Edge: Equatable {
    public static func == (lha:Edge, rha:Edge) -> Bool {
        return lha.from == rha.from && lha.to == rha.to
    }
}
