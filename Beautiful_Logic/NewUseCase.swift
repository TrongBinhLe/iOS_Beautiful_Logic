//
//  NewUseCase.swift
//  Beautiful_Logic
//
//  Created by admin on 12/08/2024.
//

import Foundation
import Combine

protocol FeatureUseCase: AnyObject {
    func execute()
}

protocol FeatureUseCaseWithResult: AnyObject {
    associatedtype Result
    associatedtype E: Error
    func execute() -> AnyPublisher<Result, E>
}

