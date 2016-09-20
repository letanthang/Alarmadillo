//
//  Helper.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/16/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import Foundation

struct Helper {
    static func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = path[0]
        return documentsDirectory
    }
}
