//
//  AppDelegate+Log.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 28. 10. 2024..
//

import SwiftyBeaver

let log = SwiftyBeaver.self

extension AppDelegate {
    
    func setupLogger() {
        let console = ConsoleDestination()
        log.addDestination(console)
        let file = FileDestination()
        log.addDestination(file)
        console.format = "$DHH:mm:ss$d $L $H $M"
        console.logPrintWay = .logger(subsystem: "Main", category: "UI")
    }
    
}

