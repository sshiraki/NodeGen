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
    var fromNode:Node!
    var toNode:Node!
    
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
        
        // タップのUIGestureRecognrを生成.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(gestureRecognizer:)))
        // MapViewにUIGestureRecognizerを追加.
        view.addGestureRecognizer(tapGesture)
        
        // 長押しのUIGestureRecognizerを生成.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGesture(sender:)))
        // MapViewにUIGestureRecognizerを追加.
        view.addGestureRecognizer(longPressGesture)
        longPressGesture.minimumPressDuration = 0.5
        
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
        
            // pinのクラス名を取得
            switch NSStringFromClass(type(of: annotation)).components(separatedBy: ".").last! as String {
                
            case "NodeAnnotation":
                
                // ( annotation as! NodeAnnotation )
                // NodeAnnotationクラスで定義した変数を取る
                print((annotation as! NodeAnnotation).node!)
                
            default: break
            }
            
            // すでにpinがカスタマイズされている場合はそのまま表示
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("taped")
       //処理
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        toNode = fromNode
        fromNode = (view.annotation as! NodeAnnotation).node!
        if (toNode == nil ){ return }
        if (fromNode == toNode ){ return }

        let cofrom = CLLocationCoordinate2DMake(fromNode.location.latitude,fromNode.location.longitude)
        let coto = CLLocationCoordinate2DMake(toNode.location.latitude,toNode.location.longitude)        // 始点と終点のMKPlacemarkを生成
        let fromPlacemark = MKPlacemark(coordinate:cofrom, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:coto, addressDictionary:nil)
            
        // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)
        // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirections.Request()
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.any
        // 経路検索
        let directions = MKDirections(request:request)
        directions.calculate(completionHandler: {
            (response, error) in
            
            if error != nil {
                print("Error :",error.debugDescription)
            } else {
                mapView.addOverlay((response!.routes[0].polyline))
                //showRoute(view, response: response!)
                // Nodeが設定されてなければ、追加
                let edge = Edge(from: self.graph.nodes.index(of: self.fromNode)!, to: self.graph.nodes.index(of: self.toNode)!, length: response!.routes[0].distance)
                if self.fromNode.edges.index(of: edge) == nil {
                    self.fromNode.edges.append(edge)
                }
                print(self.fromNode, self.toNode)
            }
        })
        
    }
    
    @objc func tapGesture(gestureRecognizer: UITapGestureRecognizer){
        let view = gestureRecognizer.view
        let tapPoint = gestureRecognizer.location(in: view)

        //ピン部分のタップだったらリターン
        if tapPoint.x >= 0 && tapPoint.y >= 0 {
            print("pin taped")
//            toNode =
            return
        }
        self.fromNode = nil
        print("pin 以外")
        //処理
    }
    
    /* 長押しを感知した際に呼ばれるメソッド. */
    @objc func longPressGesture(sender: UILongPressGestureRecognizer) {
        
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        // ピンを生成
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        // タイトルを設定.
        myPin.title = "タイトル"
 
        // サブタイトルを設定.
        myPin.subtitle = "サブタイトル"
        
        
        
    }
}
