//
//  Logger.swift
//  WayPay
//
//  Created by Oscar Anzola on 17/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

struct Logger {
    static func message(fileName: String = #file, functionName: String = #function, _ message: String = "") {
        if (OperationEnvironment.isLogginOn) {
            var fileNameLastComponent = URL(fileURLWithPath: fileName)
            fileNameLastComponent = fileNameLastComponent.deletingPathExtension()
            print("\n\n>>\(fileNameLastComponent.lastPathComponent): \(functionName): \(message)")
        }
    }
}
