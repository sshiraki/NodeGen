//
//  Graphmk.swift
//  NodeGen
//
//  Created by SUNAO SHIRAKI on 2018/11/04.
//  Copyright © 2018年 SUNAO SHIRAKI. All rights reserved.
//

import MapKit

struct Graph{
    static var verbose = false
    private var nodes:[Node]
    
    static func getJsonData() -> Data? {
        let file = "../map"
        let path = Bundle.main.path(forResource: file, ofType: "json")!
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    enum GraphError: Error {
        case invalidJsonError
    }
    
    init() throws {
        guard let jsonData =  Graph.getJsonData() else {
            throw GraphError.invalidJsonError
        }
        guard let json = try JSONSerialization.jsonObject(with:jsonData) as? [String:Any] else {
            throw GraphError.invalidJsonError
        }
        guard let nodeArray = json["nodes"] as? [[String:Any]] else {
            throw GraphError.invalidJsonError
        }
        self.nodes = try nodeArray.map{ (node) -> Node in
            guard let edgeArray = node["edges"] as? [[String:Any]] else {
                throw GraphError.invalidJsonError
            }
            let edges = try edgeArray.map{ (edge) -> Edge in
                guard let from = edge["from"] as? Int,
                    let to = edge["to"] as? Int,
                    let length = edge["length"] as? CLLocationDistance else {
                        throw GraphError.invalidJsonError
                }
                return Edge(from:from , to:to , length:length)
            }
            guard let location = node["location"] as? [String:Any],
                let x = location["x"] as? CLLocationDegrees,
                let y = location["y"] as? CLLocationDegrees else {
                    throw GraphError.invalidJsonError
            }
            return Node(location:CLLocationCoordinate2D(latitude: y, longitude: x), edges: edges)
        }
        self.nodes = Graph.updateLength(nodes: self.nodes)
    }
    
    static func updateLength(nodes: [Node]) -> [Node] {
        return nodes.map({ (node) -> Node in
            let edges = node.edges.map({ (edge) -> Edge in
                let node0 = nodes[edge.from]
                let node1 = nodes[edge.to]
                return Edge(from: edge.from, to: edge.to, length: node0.distance(to: node1))
            })
            return Node(location: node.location, edges: edges)
        })
    }
    
    func location(at index:Int) -> CLLocationCoordinate2D {
        return nodes[index].location
    }
    
    func render(view:MKMapView, ctx:CGContext, frame:CGRect, scale:CGFloat) {
        UIColor.white.setFill()
        ctx.fill(frame)
        ctx.setLineWidth(Metrics.roadWidth)
        UIColor.lightGray.setFill()
        UIColor.lightGray.setStroke()
        
        for node in nodes {
            node.render(view:view, graph:self)
        }
    }

    var dictionary:[String:Any]  {
        return [
            "nodes": self.nodes.map {$0.dictionary}
        ]
    }
    
    var json: String {
        let jsonData =  try! JSONSerialization.data(withJSONObject: dictionary);
        return String(bytes: jsonData, encoding: .utf8)!
    }

}
