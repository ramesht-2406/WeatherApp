//
//  Bindable.swift
//  WeatherApp
//
//  Created by Ramesh Thangalapally on 09/05/23.
//

import Foundation

class Bindable<T> {
    typealias Listener = (T) -> Void
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
