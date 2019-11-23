//
//  ContentView.swift
//  barometer_swiftui
//
//  Created by bell on 2019/11/22.
//  Copyright © 2019 MAXQ. All rights reserved.
//

import Combine
import SwiftUI
import CoreMotion

class AltimatorManager: NSObject, ObservableObject {
    let willChange = PassthroughSubject<Void, Never>()
    
    var altimeter:CMAltimeter?

    @Published var pressureString:String = ""
    @Published var altitudeString:String = ""
    
    override init() {
        super.init()
        altimeter = CMAltimeter()
        startUpdate()
    }
    
    func doReset(){
        altimeter?.stopRelativeAltitudeUpdates()
        startUpdate()
    }
    
    func startUpdate() {
        if(CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter!.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler:
                {data, error in
                    if error == nil {
                        let pressure:Double = data!.pressure.doubleValue
                        let altitude:Double = data!.relativeAltitude.doubleValue
                        self.pressureString = String(format: "気圧:%.1f hPa", pressure * 10)
                        self.altitudeString = String(format: "高さ:%.2f m",altitude)
                        self.willChange.send()
                    }
            })
        }
    }

}

struct ContentView: View {
    @ObservedObject var manager = AltimatorManager()
    
    let availabe = CMAltimeter.isRelativeAltitudeAvailable()

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 30) {
                Text(availabe ? manager.pressureString : "----")
                Text(availabe ? manager.altitudeString : "----")
            }
            Button(action: {
                self.manager.doReset()
            }) {
                Text("リセット")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
