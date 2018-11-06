//
//  Node.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import CoreGraphics
import MapKit

// A Node represents a location where shuttles can pick up or drop riders
struct Node {
    static let image = UIImage(named: "busstop.png")!
    enum NodeType {
        case empty
        case start
        case end
        case used
    }
    
    let location:CLLocationCoordinate2D // The location
    let edges:[Edge]     // Edges started from this node (one direction)
    let type:NodeType    // Node type. Used only when we are searching a shortest route
    
    init(location:CLLocationCoordinate2D, edges:[Edge]) {
        self.location = location
        self.edges = edges
        self.type = .empty
    }
    
    init(node:Node, type:NodeType) {
        self.location = node.location
        self.edges = node.edges
        self.type = type
    }
    
    func distance(to:Node) -> CLLocationDistance {
        let locationFrom = CLLocation(latitude: self.location.latitude,longitude: self.location.longitude)
        let locationTo = CLLocation(latitude: to.location.latitude, longitude: to.location.longitude)
        return locationTo.distance(from: locationFrom)
    }
    
    func render(view:MKMapView, graph:Graph) {
        // 地図にピンを立てる
        let an = MKPointAnnotation()
        an.coordinate = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)
        Metricsmk.image = Node.image
        view.addAnnotation(an)

        // edgeの元に円を描く
        view.addOverlay(MKCircle(center:self.location, radius:10))
        
        // edge間の線を引く
        
        for edge in edges {
            if (edge.from != 0 && edge.to != 0) {
                edge.addPath(view: view, graph: graph)
            }
        }
    }

    var dictionary:[String:Any] {
        return [
          "location": [
            "x": self.location.longitude,
            "y": self.location.latitude,
          ],
          "edges": edges.map { $0.dictionary }
        ];
    }
}

