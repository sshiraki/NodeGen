//
//  Route.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import CoreGraphics
import MapKit

// A Route represents a section of trip from one node to another consisting of connected edges.
struct Route {
    let edges:[Edge]
    let length:CLLocationDistance
    let extra:CGFloat // used only when finding a shortest route
    var pickups = Set<Int>() // identifiers of riders to be picked up 
    var from:Int { return edges.first!.from }
    var to:Int { return edges.last!.to }

    init(edges:[Edge], extra:CGFloat = 0) {
        self.edges = edges
        self.length = edges.reduce(0) { $0 + $1.length }
        self.extra = extra
    }

    func render(view:MKMapView, graph:Graph) {
        let locationFrom = graph.location(at: edges[0].from)
        let dr = Direction()
        for edge in edges {
            let locationTo = graph.location(at: edge.to)
            dr.addRoute(view: view, locationFrom: locationFrom, locationTo: locationTo)
        }
    }
}

extension Route: CustomStringConvertible {
    var description: String {
        return String(format: "%3d->%3d:%@", from, to,
                      pickups.map{String($0)}.joined(separator: ","))
    }
}
