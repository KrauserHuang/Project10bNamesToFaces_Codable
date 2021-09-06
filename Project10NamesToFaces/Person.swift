//
//  Person.swift
//  Project10NamesToFaces
//
//  Created by Tai Chin Huang on 2021/9/2.
//

import UIKit

class Person: NSObject, Codable {
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
