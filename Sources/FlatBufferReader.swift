//
//  FlatBufferReader.swift
//  SwiftFlatBuffers
//
//  Created by Maxim Zaks on 21.11.15.
//  Copyright © 2015 maxim.zaks. All rights reserved.
//
import Foundation

public enum FlatBufferReaderError : ErrorProtocol {
    case canOnlySetNonDefaultProperty
}

public final class FlatBufferReader {

    public static var maxInstanceCacheSize : UInt = 0 // max number of cached instances
    static var instancePool : [FlatBufferReader] = []
    
    public var config : BinaryReadConfig
    
    var buffer = UnsafeMutablePointer<UInt8>(nil)
    public var objectPool : [Offset : AnyObject] = [:]
    
    func fromByteArray<T : Scalar>(_ position : Int) -> T{
        return UnsafePointer<T>(buffer!.advanced(by: position)).pointee
    }
    
    private var length : Int
    public var data : [UInt8] {
        return Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(buffer), count: length))
    }

    public init(buffer : [UInt8], config: BinaryReadConfig){
        self.buffer = UnsafeMutablePointer<UInt8>(buffer)
        self.config = config
        length = buffer.count
    }
    
    public init(bytes : UnsafeBufferPointer<UInt8>, config: BinaryReadConfig){
        self.buffer = UnsafeMutablePointer<UInt8>(bytes.baseAddress)
        self.config = config
        length = bytes.count
    }

    public init(bytes : UnsafeMutablePointer<UInt8>, count : Int, config: BinaryReadConfig){
        self.buffer = bytes
        self.config = config
        length = count
    }

    public var rootObjectOffset : Offset {
        let offset : Int32 = fromByteArray(0)
        return offset
    }
    
    public func get<T : Scalar>(_ objectOffset : Offset, propertyIndex : Int, defaultValue : T) -> T{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return defaultValue
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(position)
    }
    
    public func get<T : Scalar>(_ objectOffset : Offset, propertyIndex : Int) -> T?{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(position) as T
    }
    
    public func set<T : Scalar>(_ objectOffset : Offset, propertyIndex : Int, value : T) throws {
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            throw FlatBufferReaderError.canOnlySetNonDefaultProperty
        }
        var v = value
        let position = Int(objectOffset + propertyOffset)
        let c = strideofValue(v)
        withUnsafePointer(&v){
            buffer!.advanced(by: position).assignFrom(UnsafeMutablePointer<UInt8>($0), count: c)
        }
    }
    
    public func hasProperty(_ objectOffset : Offset, propertyIndex : Int) -> Bool {
        return getPropertyOffset(objectOffset, propertyIndex: propertyIndex) != 0
    }
    
    public func getOffset(_ objectOffset : Offset, propertyIndex : Int) -> Offset?{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = objectOffset + propertyOffset
        let localObjectOffset : Int32 = fromByteArray(Int(position))
        let offset = position + localObjectOffset
        
        if localObjectOffset == 0 {
            return nil
        }
        return offset
    }
    
    var stringCache : [Int32:String] = [:]
    
    public func getString(_ stringOffset : Offset?) -> String? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        if config.uniqueStrings {
            if let result = stringCache[stringOffset]{
                return result
            }
        }
        
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(stringPosition)
        
        let pointer = UnsafeMutablePointer<UInt8>(buffer!).advanced(by: (stringPosition + strideof(Int32.self)))
        let result = String.init(bytesNoCopy: pointer, length: Int(stringLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        
        if config.uniqueStrings {
            stringCache[stringOffset] = result
        }
        return result
    }
    
    public func getStringBuffer(_ stringOffset : Offset?) -> UnsafeBufferPointer<UInt8>? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(stringPosition)
        let pointer = UnsafePointer<UInt8>(buffer!).advanced(by: (stringPosition + strideof(Int32.self)))
        return UnsafeBufferPointer<UInt8>.init(start: pointer, count: Int(stringLength))
    }
    
    public func getVectorLength(_ vectorOffset : Offset?) -> Int {
        guard let vectorOffset = vectorOffset else {
            return 0
        }
        let vectorPosition = Int(vectorOffset)
        let length2 : Int32 = fromByteArray(vectorPosition)
        return Int(length2)
    }
    
    public func getVectorScalarElement<T : Scalar>(_ vectorOffset : Offset, index : Int) -> T {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(T.self)))
        return UnsafePointer<T>(UnsafePointer<UInt8>(buffer!).advanced(by: valueStartPosition)).pointee
    }
    
    public func setVectorScalarElement<T : Scalar>(_ vectorOffset : Offset, index : Int, value : T) {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(T.self)))
        var v = value
        let c = strideofValue(v)
        withUnsafePointer(&v){
            buffer!.advanced(by: valueStartPosition).assignFrom(UnsafeMutablePointer<UInt8>($0), count: c)
        }
    }
    
    public func getVectorOffsetElement(_ vectorOffset : Offset, index : Int) -> Offset? {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(Int32.self)))
        let localOffset : Int32 = fromByteArray(valueStartPosition)
        if(localOffset == 0){
            return nil
        }
        return localOffset + valueStartPosition
    }
    
    private func getPropertyOffset(_ objectOffset : Offset, propertyIndex : Int)->Int {
        let offset = Int(objectOffset)
        let localOffset : Int32 = fromByteArray(offset)
        let vTableOffset : Int = offset - Int(localOffset)
        let vTableLength : Int16 = fromByteArray(vTableOffset)
        if(vTableLength<=Int16(4 + propertyIndex * 2)) {
            return 0
        }
        let propertyStart = vTableOffset + 4 + (2 * propertyIndex)
        
        let propertyOffset : Int16 = fromByteArray(propertyStart)
        return Int(propertyOffset)
    }
}

public extension FlatBufferReader {
    public func reset ()
    {
        buffer = nil
        objectPool.removeAll(keepingCapacity: true)
        stringCache.removeAll(keepingCapacity: true)
        length = 0
    }
    
    public static func create(_ buffer : [UInt8], config: BinaryReadConfig) -> FlatBufferReader {
        objc_sync_enter(instancePool)
        defer { objc_sync_exit(instancePool) }

        if (instancePool.count > 0)
        {
            let reader = instancePool.removeLast()
            
            reader.buffer = UnsafeMutablePointer<UInt8>(buffer)
            reader.config = config
            reader.length = buffer.count
            
            return reader
        }
        
        return FlatBufferReader(buffer: buffer, config: config)
    }
    
    public static func create(_ bytes : UnsafeBufferPointer<UInt8>, config: BinaryReadConfig) -> FlatBufferReader {
        objc_sync_enter(instancePool)
        defer { objc_sync_exit(instancePool) }

        if (instancePool.count > 0)
        {
            let reader = instancePool.removeLast()
            
            reader.buffer = UnsafeMutablePointer(bytes.baseAddress)
            reader.config = config
            reader.length = bytes.count
            
            return reader
        }
        
        return FlatBufferReader(bytes: bytes, config: config)
    }
    
    public static func create(_ bytes : UnsafeMutablePointer<UInt8>, count : Int, config: BinaryReadConfig) -> FlatBufferReader {
        objc_sync_enter(instancePool)
        defer { objc_sync_exit(instancePool) }

        if (instancePool.count > 0)
        {
            let reader = instancePool.removeLast()
            
            reader.buffer = bytes
            reader.config = config
            reader.length = count
            
            return reader
        }
        
        return FlatBufferReader(bytes: bytes, count: count, config: config)
    }

    public static func reuse(_ reader : FlatBufferReader) {
        objc_sync_enter(instancePool)
        defer { objc_sync_exit(instancePool) }

        if (UInt(instancePool.count) < maxInstanceCacheSize)
        {
            reader.reset()
            instancePool.append(reader)
        }
    }
}


// MARK: Fast Reader

public final class FlatBufferReaderFast {

    public static func fromByteArray<T : Scalar>(_ buffer : UnsafePointer<UInt8>, _ position : Int) -> T{
        return UnsafePointer<T>(buffer.advanced(by: position)).pointee
    }

    public static func getPropertyOffset(_ buffer : UnsafePointer<UInt8>, _ objectOffset : Offset, propertyIndex : Int)->Int {
        let offset = Int(objectOffset)
        let localOffset : Int32 = fromByteArray(buffer, offset)
        let vTableOffset : Int = offset - Int(localOffset)
        let vTableLength : Int16 = fromByteArray(buffer, vTableOffset)
        if(vTableLength<=Int16(4 + propertyIndex * 2)) {
            return 0
        }
        let propertyStart = vTableOffset + 4 + (2 * propertyIndex)

        let propertyOffset : Int16 = fromByteArray(buffer, propertyStart)
        return Int(propertyOffset)
    }

    public static func getOffset(_ buffer : UnsafePointer<UInt8>, _ objectOffset : Offset, propertyIndex : Int) -> Offset?{
        let propertyOffset = getPropertyOffset(buffer, objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = objectOffset + propertyOffset
        let localObjectOffset : Int32 = fromByteArray(buffer, Int(position))
        let offset = position + localObjectOffset

        if localObjectOffset == 0 {
            return nil
        }
        return offset
    }

    public static func getVectorLength(_ buffer : UnsafePointer<UInt8>, _ vectorOffset : Offset?) -> Int {
        guard let vectorOffset = vectorOffset else {
            return 0
        }
        let vectorPosition = Int(vectorOffset)
        let length2 : Int32 = fromByteArray(buffer, vectorPosition)
        return Int(length2)
    }

    public static func getVectorOffsetElement(_ buffer : UnsafePointer<UInt8>, _ vectorOffset : Offset, index : Int) -> Offset? {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(Int32.self)))
        let localOffset : Int32 = fromByteArray(buffer, valueStartPosition)
        if(localOffset == 0){
            return nil
        }
        return localOffset + valueStartPosition
    }

    public static func getVectorScalarElement<T : Scalar>(_ buffer : UnsafePointer<UInt8>, _ vectorOffset : Offset, index : Int) -> T {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(T.self)))
        return UnsafePointer<T>(UnsafePointer<UInt8>(buffer).advanced(by: valueStartPosition)).pointee
    }

    public static func get<T : Scalar>(_ buffer : UnsafePointer<UInt8>, _ objectOffset : Offset, propertyIndex : Int, defaultValue : T) -> T{
        let propertyOffset = getPropertyOffset(buffer, objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return defaultValue
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(buffer, position)
    }

    public static func get<T : Scalar>(_ buffer : UnsafePointer<UInt8>, _ objectOffset : Offset, propertyIndex : Int) -> T?{
        let propertyOffset = getPropertyOffset(buffer, objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(buffer, position) as T
    }

    public static func getStringBuffer(_ buffer : UnsafePointer<UInt8>, _ stringOffset : Offset?) -> UnsafeBufferPointer<UInt8>? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(buffer, stringPosition)
        let pointer = UnsafePointer<UInt8>(buffer).advanced(by: (stringPosition + strideof(Int32.self)))
        return UnsafeBufferPointer<UInt8>.init(start: pointer, count: Int(stringLength))
    }

    public static func getString(_ buffer : UnsafePointer<UInt8>, _ stringOffset : Offset?) -> String? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(buffer, stringPosition)

        let pointer = UnsafeMutablePointer<UInt8>(buffer).advanced(by: (stringPosition + strideof(Int32.self)))
        let result = String.init(bytesNoCopy: pointer, length: Int(stringLength), encoding: String.Encoding.utf8, freeWhenDone: false)

        return result
    }

    public static func set<T : Scalar>(_ buffer : UnsafeMutablePointer<UInt8>, _ objectOffset : Offset, propertyIndex : Int, value : T) throws {
        let propertyOffset = getPropertyOffset(buffer, objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            throw FlatBufferReaderError.canOnlySetNonDefaultProperty
        }
        var v = value
        let position = Int(objectOffset + propertyOffset)
        let c = strideofValue(v)
        withUnsafePointer(&v){
            buffer.advanced(by: position).assignFrom(UnsafeMutablePointer<UInt8>($0), count: c)
        }
    }

    public static func setVectorScalarElement<T : Scalar>(_ buffer : UnsafeMutablePointer<UInt8>, _ vectorOffset : Offset, index : Int, value : T) {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(T.self)))
        var v = value
        let c = strideofValue(v)
        withUnsafePointer(&v){
            buffer.advanced(by: valueStartPosition).assignFrom(UnsafeMutablePointer<UInt8>($0), count: c)
        }
    }
}






public final class FlatBufferFileReader {
    
    public var config : BinaryReadConfig
    
    let fileHandle : FileHandle
    public var objectPool : [Offset : AnyObject] = [:]
    
    func fromByteArray<T : Scalar>(_ position : Int) -> T {
        fileHandle.seek(toFileOffset: UInt64(position))
        return fileHandle.readData(ofLength: strideof(T.self)).withUnsafeBytes { p in
            return p.pointee
        }
    }
    
    public init(filePath : String, config: BinaryReadConfig){
        self.config = config
        fileHandle = FileHandle.init(forUpdatingAtPath: filePath)!
    }
    
    public var rootObjectOffset : Offset {
        let offset : Int32 = fromByteArray(0)
        return offset
    }
    
    public func get<T : Scalar>(_ objectOffset : Offset, propertyIndex : Int, defaultValue : T) -> T{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return defaultValue
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(position)
    }
    
    public func get<T : Scalar>(_ objectOffset : Offset, propertyIndex : Int) -> T?{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = Int(objectOffset + propertyOffset)
        return fromByteArray(position) as T
    }
    
    public func hasProperty(_ objectOffset : Offset, propertyIndex : Int) -> Bool {
        return getPropertyOffset(objectOffset, propertyIndex: propertyIndex) != 0
    }
    
    public func getOffset(_ objectOffset : Offset, propertyIndex : Int) -> Offset?{
        let propertyOffset = getPropertyOffset(objectOffset, propertyIndex: propertyIndex)
        if propertyOffset == 0 {
            return nil
        }
        let position = objectOffset + propertyOffset
        let localObjectOffset : Int32 = fromByteArray(Int(position))
        let offset = position + localObjectOffset
        
        if localObjectOffset == 0 {
            return nil
        }
        return offset
    }
    
    var stringCache : [Int32:String] = [:]
    
    public func getString(_ stringOffset : Offset?) -> String? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        if config.uniqueStrings {
            if let result = stringCache[stringOffset]{
                return result
            }
        }
        
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(stringPosition)
        
        fileHandle.seek(toFileOffset: UInt64(stringPosition + strideof(Int32.self)))
        let pointer = fileHandle.readData(ofLength: Int(stringLength)).withUnsafeBytes { (p: UnsafePointer<UInt8>) in
            return UnsafeMutablePointer<UInt8>(p)
        }
        let result = String.init(bytesNoCopy: pointer, length: Int(stringLength), encoding: String.Encoding.utf8, freeWhenDone: false)
        
        if config.uniqueStrings {
            stringCache[stringOffset] = result
        }
        return result
    }
    
    public func getStringBuffer(_ stringOffset : Offset?) -> UnsafeBufferPointer<UInt8>? {
        guard let stringOffset = stringOffset else {
            return nil
        }
        let stringPosition = Int(stringOffset)
        let stringLength : Int32 = fromByteArray(stringPosition)
        
        fileHandle.seek(toFileOffset: UInt64(stringPosition + strideof(Int32.self)))
        let pointer = fileHandle.readData(ofLength: Int(stringLength)).withUnsafeBytes { (p: UnsafePointer<UInt8>) in
            return UnsafeMutablePointer<UInt8>(p)
        }
        return UnsafeBufferPointer<UInt8>(start: pointer, count: Int(stringLength))
    }
    
    public func getVectorLength(_ vectorOffset : Offset?) -> Int {
        guard let vectorOffset = vectorOffset else {
            return 0
        }
        let vectorPosition = Int(vectorOffset)
        let length2 : Int32 = fromByteArray(vectorPosition)
        return Int(length2)
    }
    
    public func getVectorScalarElement<T : Scalar>(_ vectorOffset : Offset, index : Int) -> T {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(T.self)))
        fileHandle.seek(toFileOffset: UInt64(valueStartPosition))
        
        return fileHandle.readData(ofLength: strideof(T.self)).withUnsafeBytes { p in
            return p.pointee
        }
    }
    
    public func getVectorOffsetElement(_ vectorOffset : Offset, index : Int) -> Offset? {
        let valueStartPosition = Int(vectorOffset + strideof(Int32.self) + (index * strideof(Int32.self)))
        let localOffset : Int32 = fromByteArray(valueStartPosition)
        if(localOffset == 0){
            return nil
        }
        return localOffset + valueStartPosition
    }
    
    private func getPropertyOffset(_ objectOffset : Offset, propertyIndex : Int)->Int {
        let offset = Int(objectOffset)
        let localOffset : Int32 = fromByteArray(offset)
        let vTableOffset : Int = offset - Int(localOffset)
        let vTableLength : Int16 = fromByteArray(vTableOffset)
        if(vTableLength<=Int16(4 + propertyIndex * 2)) {
            return 0
        }
        let propertyStart = vTableOffset + 4 + (2 * propertyIndex)
        
        let propertyOffset : Int16 = fromByteArray(propertyStart)
        return Int(propertyOffset)
    }
}

