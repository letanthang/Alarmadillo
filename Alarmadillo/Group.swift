//
//  Group.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/13/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit

class Group: NSObject, NSCoding {
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        playSound = aDecoder.decodeBool(forKey: "playSound")
        enabled = aDecoder.decodeBool(forKey: "enabled")
        alarms = aDecoder.decodeObject(forKey: "alarms") as! [Alarm]
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(playSound, forKey: "playSound")
        aCoder.encode(enabled, forKey: "enabled")
        aCoder.encode(alarms, forKey: "alarms")
    }
    
    var id: String
    var name: String
    var playSound: Bool
    var enabled: Bool
    var alarms: [Alarm]
    init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        self.id = UUID().uuidString
        self.name = name
        self.playSound = playSound
        self.enabled = enabled
        self.alarms = alarms
        
    }
}
