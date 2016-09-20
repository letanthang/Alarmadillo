//
//  Alarm.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/13/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit

class Alarm: NSObject, NSCoding {
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.caption = aDecoder.decodeObject(forKey: "caption") as! String
        self.time = aDecoder.decodeObject(forKey: "time") as! Date
        self.image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(caption, forKey: "caption")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(image, forKey: "image")
        
    }
    
    var id: String
    var name: String
    var caption: String
    var time: Date
    var image: String

    init(name: String, caption: String, time: Date, image: String) {
        
        self.id = UUID().uuidString
        self.caption = caption
        self.name = name
        self.time = time
        self.image = image
        
    }
    
}
