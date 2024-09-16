//
//  JSONParset.swift
//  Beautiful_Logic
//
//  Created by admin on 16/09/2024.
//

import Foundation
import SCClient

final class JSONParser {
    static func convertJsonToDictionary(jsonText: String) -> [String: Any]? {
        if jsonText.isEmpty {
            OALogError("[PP] [convertJsonToDictionary]: jsonText is nil")
            return nil
        }

        if let data = jsonText.data(using: String.Encoding.utf8) {
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
                return dic
            } catch {
                OALogError("[PP] [JSONParser] \(jsonText)")
            }
        }
        return nil
    }

    static func convertJsonToArrayOfDictionary(jsonText: String) -> [[String: Any]]? {
        if jsonText.isEmpty {
            OALogError("[PP] [convertJsonToDictionary]: jsonText is nil")
            return nil
        }

        if let data = jsonText.data(using: String.Encoding.utf8) {
            do {
                let arrayOfDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]]
                return arrayOfDictionary
            } catch {
                OALogError("[PP] [JSONParser] Error : convertJsonToDictionary")
            }
        }
        return nil
    }

    static func convertDictionaryToJson(dic: Any) -> String? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: dic, options: [])
            let json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
            return json
        } catch {
            OALogError("[PP] [JSONParser] Error : convertDictionaryToJson")
        }
        return nil
    }
    
    static func convertDataToDictionary(data: Data) -> [String: AnyObject]? {
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            return dic
        } catch {
            OALogError("[PP] [JSONParser] Error : convertJsonToDictionary")
        }
        return nil
    }
    
    static func convertDataToArray(data: Data) -> [Any]? {
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any]
            return array
        } catch {
            OALogError("[PP] Error : \(error.localizedDescription)")
            return nil
        }
    }
    
    static func convertJsonToRcsValue(dic: [String: Any]) -> OBJC_RCSRepresentation? {
        if let rcsJsonString = JSONParser.convertDictionaryToJson(dic: dic as Any) {
            if let rcsObj = OBJC_JSONConverter.toOCFRepresentation(rcsJsonString) {
                return rcsObj
            } else {
                OALogError("[PP] [JSONParser] Error converting json to ocf representation")
                return nil
            }
        } else {
            OALogError("[PP] [JSONParser] Error converting dictionary to json")
            return nil
        }
    }
    
    static func convertJsonArrayToRcsValue(dic: [[String: Any]]) -> OBJC_RCSRepresentation? {
        if let rcsJsonString = JSONParser.convertDictionaryToJson(dic: dic as Any) {
            if let rcsObj = OBJC_JSONConverter.toOCFRepresentation(rcsJsonString) {
                return rcsObj
            } else {
                OALogError("[PP] [JSONParser] Error converting json to ocf representation")
                return nil
            }
        } else {
            OALogError("[PP] [JSONParser] Error converting dictionary to json")
            return nil
        }
    }

    static func convertRcsValueToJson(_ rcsResult: OBJC_RCSRepresentation?) -> String? {
        if rcsResult == nil {
            OALogError("[PP] [JSONParser] [convertRcsValueToJson] rcsResult is nil")
            return nil
        }

        let jsonText = OBJC_JSONConverter.toJSON(rcsResult).replacingOccurrences(of: "[\r\n\t]", with: "", options: .regularExpression, range: nil)
        OALogDebug("[PP_W] [JSONParser] [convertRcsValueToJson] jsonText from OBJC_RCSRepresentation: \(String(describing: jsonText))")
        return jsonText
    }

    static func convertRcsAttributeToJson(_ rcsAttribute: OBJC_RCSResourceAttributes?) -> String? {
        guard let rcsAttributes = rcsAttribute else {
            OALogError("[PP] [JSONParser] [convertRcsAttributeToJson] rcsAttribute is nil")
            return nil
        }
        
        let rcsRepresentation = OBJC_RCSRepresentation(attrs: rcsAttributes)
        return convertRcsValueToJson(rcsRepresentation)
    }
    
    static func changeToJsJSON(_ json: String) -> String {
        /**
         * \b  Backspace
         * \f  Form feed
         * \n  New line
         * \r  Carriage return
         * \t  Tab
         * \"  Double quote
         * \'  Single quote
         * \\  Backslash character
         */
        
        let dq = "\""
        let sq = "\'"
        
        let dqp = "\\\(dq)"
        let sqp = "’"
        return json
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: dq, with: dqp)
            .replacingOccurrences(of: sq, with: sqp)
    }
    
    static func isValidJson(jsonString: String) -> Bool {
        if let jsonToVerify = jsonString.data(using: String.Encoding.utf8) {
            do {
                _ = try JSONSerialization.jsonObject(with: jsonToVerify)
            } catch {
                OALogError("[PP_W] Error deserializing JSON: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }
    
    static func convertArrayToData(array: [Any]) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            return data
        } catch {
            OALogError("[PP_W] array to data conversion failed for \(error.localizedDescription)")
            return nil
        }
    }
    
    static func convertJsonToArray(jsonText: String) -> [AnyObject]? {
        if let data = jsonText.data(using: String.Encoding.utf8) {
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [AnyObject]
                return dic
            } catch {
                OALogWarn("[JSONParser] Error : convertJsonToArray")
            }
        }
        return nil
    }
    

    /**
     Prints json text in a pretty format.
     - Parameters:
         - jsonText: JSON object in String format
     - Returns: A String containing the pretty-printed JSON. Will return empty string if input JSON is invalid.
     ```
     // How the json will look in console:
     {
        "name": "Steve Jobs",
        "username": "Steve",
        "address": {
          "street": "Kulas Light",
          "city": "San Jose",
        }
      }
     ```
     */
    static func prettyPrintedJson(jsonText: String) -> String {
        guard let jsonData = jsonText.data(using: .utf8) else {
            OALogError("[JSONParser] Unable to parse and pretty-print json text")
            return ""
        }
        
        return prettyPrintedJson(jsonData: jsonData)
    }
    
    /**
     Prints json text in a pretty format.
     - Parameters:
         - jsonText: JSON object in Data format
     - Returns: A String containing the pretty-printed JSON. Will return empty string if input JSON is invalid.
     ```
     // How the json will look in console:
     {
        "name": "Steve Jobs",
        "username": "Steve",
        "address": {
          "street": "Kulas Light",
          "city": "San Jose",
        }
      }
     ```
     */
    static func prettyPrintedJson(jsonData: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: jsonData),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let prettyPrintedString = String(data: data, encoding: .utf8)
        else {
            OALogError("[JSONParser] Unable to parse and pretty-print json text")
            return ""
        }
        
        return prettyPrintedString
    }
    
    static func convertDataToJsonString(jsonData: Data) -> String? {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys]),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            OALogInfo("[PP_W] Response data not in JSON format. Proceeding to UTF8 string conversion.")
            return String(decoding: jsonData, as: UTF8.self)
        }
        return jsonString
    }
}
