//
//  Assembler.swift
//  Beautiful_Logic
//
//  Created by admin on 12/08/2024.
//

import Foundation

class Assembler {
    var assembles = SafeDictionary<String, Any>()

    func register<T>(_ assemble: @escaping () -> T) {
        let key = String(describing: T.self)
        register(key: key, assemble)
    }

    func register<T>(key: String, _ assemble: @escaping () -> T) {
        guard assembles.contains(key) == false else {
            fatalError("Already registered: \(key)")
        }
        assembles[key] = assemble
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        return resolve(key: key)
    }
    
    func resolve<T>(key: String) -> T {
        guard let maker = assembles[key] as? () -> T else {
            fatalError("not found \(key)")
        }
        
        return maker()
    }
    
    func optionallyResolve<T>() -> T? {
        let key = String(describing: T.self)
        return optionallyResolve(key: key)
    }
    
    func optionallyResolve<T>(key: String) -> T? {
        (assembles[key] as? () -> T)?()
    }

    func removeAll() {
        assembles.removeAll()
    }
}
