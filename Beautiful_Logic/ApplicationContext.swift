//
//  ApplicationContext.swift
//  Beautiful_Logic
//
//  Created by admin on 12/08/2024.
//

import Foundation

protocol ApplicationContextInterface {
    func resolve<T>() -> T
    func optionallyResolve<T>() -> T?
    func resolve<T>(key: String) -> T
    func destroy()
}

protocol CommonApplicationContextInterface: ApplicationContextInterface {
    func configure()
    func register<T>(_ assemble: @escaping () -> T)
    func register<T>(key: String, _ assemble: @escaping () -> T)
    func registerSingleton<T>(_ assemble: @escaping () -> T)
    func registerLazySingleton<T>(_ assemble: @escaping () -> T)
    func registerSingleton<T>(key: String, _ assemble: @escaping () -> T)
    func registerLazySingleton<T>(key: String, _ assemble: @escaping () -> T)
}

class CommonApplicationContext: CommonApplicationContextInterface {
    private(set) var factory = Assembler()
    private(set) var singletonMap =  SafeDictionary<String, Any>()
    private(set) var candidateSingletonList = SafeSet<String>()
    init() {
        configure()
    }

    deinit {
        CLLogDebug(.UG, "CommonApplicationContext.deinit")
    }
    
    func destroy() {
        singletonMap.removeAll()
        factory.removeAll()
    }

    /// use this method when the use case may happens before the Context creation, espectially in FirstScreen
    func optionallyResolve<T>() -> T? {
        let key = String(describing: T.self)
        if candidateSingletonList.contains(key) {
            candidateSingletonList.remove(key)
            if singletonMap[key] == nil {
                singletonMap[key] = factory.optionallyResolve() as T?
            }
        }
        guard let object = singletonMap[key] as? T else {
            return factory.optionallyResolve() as T?
        }
        return object
    }

    func resolve<T>() -> T {
        let key = String(describing: T.self)
        if candidateSingletonList.contains(key) {
            candidateSingletonList.remove(key)
            if singletonMap[key] == nil {
                singletonMap[key] = factory.resolve() as T
            }
        }
        guard let object = singletonMap[key] as? T else {
            return factory.resolve() as T
        }
        return object
    }

    func resolve<T>(key: String) -> T {
        if candidateSingletonList.contains(key) {
            candidateSingletonList.remove(key)
            if singletonMap[key] == nil {
                singletonMap[key] = factory.resolve(key: key)
            }
        }
        guard let object = singletonMap[key] as? T else {
            return factory.resolve(key: key)
        }
        return object
    }

    func configure() {

    }

    func register<T>(_ assemble: @escaping () -> T) {
        factory.register(assemble)
    }

    func register<T>(key: String, _ assemble: @escaping () -> T) {
        factory.register(key: key, assemble)
    }

    func registerSingleton<T>(_ assemble: @escaping () -> T) {
        let key = String(describing: T.self)
        if singletonMap[key] != nil {
            return
        }
        self.register(assemble)
        singletonMap[key] = factory.resolve(key: key) as T
    }
    
    func registerLazySingleton<T>(_ assemble: @escaping () -> T) {
        let key = String(describing: T.self)
        if singletonMap[key] != nil {
            return
        }
        self.register(assemble)
        candidateSingletonList.insert(key)
    }

    func registerSingleton<T>(key: String, _ assemble: @escaping () -> T) {
        if singletonMap[key] != nil {
            return
        }
        self.register(key: key, assemble)
        singletonMap[key] = factory.resolve(key: key) as T
    }
    
    func registerLazySingleton<T>(key: String, _ assemble: @escaping () -> T) {
        if singletonMap[key] != nil {
            return
        }
        self.register(key: key, assemble)
        candidateSingletonList.insert(key)
    }
}
