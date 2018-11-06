//
//  ViewController.swift
//  NodeGen
//
//  Created by SUNAO SHIRAKI on 2018/11/04.
//  Copyright © 2018年 SUNAO SHIRAKI. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var viewMain: UIView!
    var graph = try! Graph()
    var scale = CGFloat(1.0)
    var mapView:MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = view.frame
        mapView = MKMapView(frame: frame)
        mapView.delegate = self
        
        scale = min(frame.size.width / CGFloat(Metrics.graphWidth + 1),
                    frame.size.height / CGFloat(Metrics.graphHeight+1)) / Metrics.edgeLength
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let ctx = UIGraphicsGetCurrentContext()!
        //graph.render(ctx:ctx, frame: frame, scale:scale)
        graph.render(view:mapView, ctx:ctx , frame: frame, scale:scale)
        
        print(graph.json);
        //mapView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 中心座標 Center Location
        let center = CLLocationCoordinate2DMake(Metricsmk.centery, Metricsmk.centerx)
        // 表示範囲 Coordinate Span
        let span = MKCoordinateSpan(latitudeDelta: Metricsmk.defaultspan, longitudeDelta: Metricsmk.defaultspan)
        // 中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated:false)
        
        viewMain.addSubview(mapView)
        
    }
    
    static func getJsonString() -> String {
        let file = "../map"
        let path = Bundle.main.path(forResource: file, ofType: "json")!
        
        var ret = "";
        if let data = NSData(contentsOfFile: path){
            ret = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
        }
        return ret;
        
    }
    
    // ピン描画前の呼び出しメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {   
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.glyphImage = Metricsmk.image
        
        } else {
            pinView?.annotation = annotation
        }
        
        pinView?.canShowCallout = true  // タップで吹き出しを表示
        return pinView
    }
    
    // 描画前の呼び出しメソッド
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //円と多角形の場合でインスタンスのクラスを分ける。
        let renderer:MKOverlayPathRenderer
        if overlay is MKCircle {
            renderer = MKCircleRenderer(overlay:overlay)
            // 線の太さを指定.
            renderer.lineWidth = Metricsmk.maproadwidth
            // 線の色を指定.
            renderer.strokeColor = Metricsmk.maproadcolor
        } else if overlay is MKPolyline {
            renderer = MKPolylineRenderer(overlay:overlay)
            // 線の太さを指定.
            renderer.lineWidth = Metricsmk.maproadwidth
            // 線の色を指定.
            renderer.strokeColor = Metricsmk.maproadcolor
        } else {
            renderer = MKPolygonRenderer(overlay:overlay)
        }
        return renderer
    }
}
