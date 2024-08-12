//
//  WifiInterface.swift
//  Beautiful_Logic
//
//  Created by admin on 12/08/2024.
//


import Foundation
import SystemConfiguration.CaptiveNetwork

class WiFiInterface {
    static var tv_id: String?

    static var bssid: String? {
        var currentBSSID: String?
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if let unsafeInterfaceData = unsafeInterfaceData, let interfaceData = unsafeInterfaceData as? Dictionary<String, AnyObject> {
                    currentBSSID = interfaceData["BSSID"] as? String
                }
            }
        }
        return currentBSSID
    }

    static var ipAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "pdp_ip0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }

    static var updateWiFiInfoData: [String: Any] {
        var action = [String: Any]()
        var data = [String: Any]()
        var json = [String: Any]()

        data["isConnected"] = 1
        data["bssid"] = bssid ?? ""
        data["ipv4"] = ipAddress ?? ""
        action["action"] = "updateWiFiInfo"
        action["data"] = data
        json["version"] = "0.1"
        json["mobile_id"] = UIDevice.uniqueMobileId
        json["request"] = action

        return json
    }

    static var getWiFiInfoData: [String: Any] {
        var action = [String: Any]()
        var data = [String: Any]()
        var json = [String: Any]()

        data["isConnected"] = (bssid == nil || ipAddress == nil) ? 0 : 1
        data["bssid"] = bssid ?? ""
        data["ipv4"] = ipAddress ?? ""
        action["action"] = "getWiFiInfo"
        action["data"] = data
        action["error"] = 0
        json["version"] = "0.1"
        json["mobile_id"] = UIDevice.uniqueMobileId
        json["tv_id"] = tv_id
        json["response"] = action

        return json
    }

    static var notifyStatusData: [String: Any] {
        var action = [String: Any]()
        var json = [String: Any]()

        action["action"] = "notifyDetectedStatus"
        action["error"] = 0
        json["version"] = "0.1"
        json["mobile_id"] = UIDevice.uniqueMobileId
        json["tv_id"] = tv_id
        json["response"] = action

        return json
    }

//    static func isDetectedTV() -> Bool {
//        if let deviceId = CLEngine.sharedEngine.getScDeviceInfo()?.getCloudDevice()?.deviceId {
//            if TVUserDefaults.core.shared().object(forKey: "Detected_\(deviceId)") != nil {
//                if TVUserDefaults.core.shared().integer(forKey: "Detected_\(deviceId)") == 1 {
//                    return true
//                } else {
//                    return false
//                }
//            } else {
//                TVUserDefaults.core.shared().set(0, forKey: "Detected_\(deviceId)")
//                TVUserDefaults.core.shared().synchronize()
//                return false
//            }
//        }
//        return true
//    }
}
