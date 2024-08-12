//
//  NormalDecode.swift
//  Beautiful_Logic
//
//  Created by admin on 12/08/2024.
//

import Foundation
import Combine

enum EnumPoint: String {
    case leftTop = "LeftTop"
    case centerTop = "CenterTop"
    case rightTop = "RightTop"
    
    case leftBottom = "LeftBottom"
    case centerBottom = "CenterBottom"
    case rightBottom = "RightBottom"
    
    case leftCenter = "LeftCenter"
    case rightCenter = "RightCenter"
}

struct _AvailableResponse: Decodable {
    let upAvailable: Bool
    let downAvailable: Bool
    let leftAvailable: Bool
    let rightAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case upAvailable = "up_available"
        case downAvailable = "down_available"
        case leftAvailable = "left_available"
        case rightAvailable = "right_available"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let upRawValue = try values.decode(String.self, forKey: .upAvailable)
        upAvailable = upRawValue == "Y" ? true : false
        
        let downRawValue = try values.decode(String.self, forKey: .downAvailable)
        downAvailable = downRawValue == "Y" ? true : false
        
        let leftRawValue = try values.decode(String.self, forKey: .leftAvailable)
        leftAvailable = leftRawValue == "Y" ? true : false
        
        let rightRawValue = try values.decode(String.self, forKey: .rightAvailable)
        rightAvailable = rightRawValue == "Y" ? true : false
    }
    
    init() {
        self.upAvailable = false
        self.downAvailable = false
        self.leftAvailable = false
        self.rightAvailable = false
    }
}
