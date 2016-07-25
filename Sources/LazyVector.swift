//
//  LazyArray.swift
//  FlatBuffersSwift
//
//  Created by Maxim Zaks on 06.01.16.
//  Copyright © 2016 maxim.zaks. All rights reserved.
//

import Foundation

public final class LazyVector<T> : Sequence {
    
    private let _generator : (Int)->T?
    private let _replacer : ((Int, T)->())?
    private let _count : Int
    
    public init(count : Int, _ generator : (Int)->T?){
        _generator = generator
        _count = count
        _replacer = nil
    }
    
    public init(count : Int, _ generator : (Int)->T?, _ replacer: ((Int, T)->())? = nil){
        _generator = generator
        _count = count
        _replacer = replacer
    }
    
    public subscript(i: Int) -> T? {
        get {
            guard i >= 0 && i < _count else {
                return nil
            }
            return _generator(i)
        }
        set {
            guard let replacer = _replacer, let value = newValue else {
                return
            }
            guard i >= 0 && i < _count else {
                return
            }
            replacer(i, value)
        }
    }
    
    public var count : Int {return _count}
    
    public func makeIterator() -> AnyIterator<T> {
        var index = 0
        
        return AnyIterator {
            let value = self[index]
            index += 1
            return value
        }
    }
}
