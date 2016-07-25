
// generated with FlatBuffersSchemaEditor https://github.com/mzaks/FlatBuffersSchemaEditor

import Foundation

public enum Enum : Int16 {
    case apples, pears, bananas
}

extension Enum {
    
    func toJSON() -> String {
        switch self {
        case apples:
            return "\"Apples\""
        case pears:
            return "\"Pears\""
        case bananas:
            return "\"Bananas\""
        }
    }
    
    static func fromJSON(_ value : String) -> Enum? {
        switch value {
        case "Apples":
            return apples
        case "Pears":
            return pears
        case "Bananas":
            return bananas
        default:
            return nil
        }
    }
}
		
public struct Foo : Scalar {
	public let id : UInt64
	public let count : Int16
	public let prefix : Int8
	public let length : UInt32
}

public func ==(v1:Foo, v2:Foo) -> Bool {
	return  v1.id==v2.id &&  v1.count==v2.count &&  v1.prefix==v2.prefix &&  v1.length==v2.length
}

extension Foo {
	public func toJSON() -> String{
		let idProperty = "\"id\":\(id)"
		let countProperty = "\"count\":\(count)"
		let prefixProperty = "\"prefix\":\(prefix)"
		let lengthProperty = "\"length\":\(length)"
		return "{\(idProperty),\(countProperty),\(prefixProperty),\(lengthProperty)}"
	}
	
	public static func fromJSON(_ dict : NSDictionary) -> Foo {
		return Foo(
		id: (dict["id"] as! NSNumber).uint64Value,
		count: (dict["count"] as! NSNumber).int16Value,
		prefix: (dict["prefix"] as! NSNumber).int8Value,
		length: (dict["length"] as! NSNumber).uint32Value
		)
	}
}

public struct Bar : Scalar {
	public let parent : Foo
	public let time : Int32
	public let ratio : Float32
	public let size : UInt16
}

public func ==(v1:Bar, v2:Bar) -> Bool {
	return  v1.parent==v2.parent &&  v1.time==v2.time &&  v1.ratio==v2.ratio &&  v1.size==v2.size
}

extension Bar {
	public func toJSON() -> String{
		let parentProperty = "\"parent\":\(parent.toJSON())"
		let timeProperty = "\"time\":\(time)"
		let ratioProperty = "\"ratio\":\(ratio)"
		let sizeProperty = "\"size\":\(size)"
		return "{\(parentProperty),\(timeProperty),\(ratioProperty),\(sizeProperty)}"
	}
	
	public static func fromJSON(_ dict : NSDictionary) -> Bar {
		return Bar(
		parent: Foo.fromJSON(dict["parent"] as! NSDictionary),
		time: (dict["time"] as! NSNumber).int32Value,
		ratio: (dict["ratio"] as! NSNumber).floatValue,
		size: (dict["size"] as! NSNumber).uint16Value
		)
	}
}

public final class FooBar {
	public static var instancePoolMutex : pthread_mutex_t = FooBar.setupInstancePoolMutex()
	public static var maxInstanceCacheSize : UInt = 0
	public static var instancePool : ContiguousArray<FooBar> = []
	public var sibling : Bar? = nil
	public var name : String? {
		get {
			if let s = name_s {
				return s
			}
			if let s = name_ss {
				name_s = String(s)
			}
			if let s = name_b {
				name_s = String.init(bytesNoCopy: UnsafeMutablePointer<UInt8>(s.baseAddress!), length: s.count, encoding: String.Encoding.utf8, freeWhenDone: false)
			}
			return name_s
		}
		set {
			name_s = newValue
			name_ss = nil
			name_b = nil
		}
	}
	public func nameStaticString(_ newValue : StaticString) {
		name_ss = newValue
		name_s = nil
		name_b = nil
	}
	private var name_b : UnsafeBufferPointer<UInt8>? = nil
	public var nameBuffer : UnsafeBufferPointer<UInt8>? {return name_b}
	private var name_s : String? = nil
	private var name_ss : StaticString? = nil
	
	public var rating : Float64 = 0
	public var postfix : UInt8 = 0
	public init(){}
	public init(sibling: Bar?, name: String?, rating: Float64, postfix: UInt8){
		self.sibling = sibling
		self.name_s = name
		self.rating = rating
		self.postfix = postfix
	}
	public init(sibling: Bar?, name: StaticString?, rating: Float64, postfix: UInt8){
		self.sibling = sibling
		self.name_ss = name
		self.rating = rating
		self.postfix = postfix
	}
}

extension FooBar : PoolableInstances {
	public func reset() { 
		sibling = nil
		name = nil
		rating = 0
		postfix = 0
	}
}

public extension FooBar {
	private static func create(_ reader : FlatBufferReader, objectOffset : Offset?) -> FooBar? {
		guard let objectOffset = objectOffset else {
			return nil
		}
		if reader.config.uniqueTables {
			if let o = reader.objectPool[objectOffset]{
				return o as? FooBar
			}
		}
		let _result = FooBar.createInstance()
		if reader.config.uniqueTables {
			reader.objectPool[objectOffset] = _result
		}
		_result.sibling = reader.get(objectOffset, propertyIndex: 0)
		_result.name_b = reader.getStringBuffer(reader.getOffset(objectOffset, propertyIndex: 1))
		_result.rating = reader.get(objectOffset, propertyIndex: 2, defaultValue: 0)
		_result.postfix = reader.get(objectOffset, propertyIndex: 3, defaultValue: 0)
		return _result
	}
}

public extension FooBar {
	public final class LazyAccess : Hashable {
		private let _reader : FlatBufferReader!
		private let _objectOffset : Offset!
		private init?(reader : FlatBufferReader, objectOffset : Offset?){
			guard let objectOffset = objectOffset else {
				_reader = nil
				_objectOffset = nil
				return nil
			}
			_reader = reader
			_objectOffset = objectOffset
		}

		public var sibling : Bar? { 
			get { return self._reader.get(_objectOffset, propertyIndex: 0)}
			set {
				if let value = newValue{
					try!_reader.set(_objectOffset, propertyIndex: 0, value: value)
				}
			}
		}
		public lazy var name : String? = self._reader.getString(self._reader.getOffset(self._objectOffset, propertyIndex: 1))
		public var rating : Float64 { 
			get { return _reader.get(_objectOffset, propertyIndex: 2, defaultValue:0)}
			set { try!_reader.set(_objectOffset, propertyIndex: 2, value: newValue)}
		}
		public var postfix : UInt8 { 
			get { return _reader.get(_objectOffset, propertyIndex: 3, defaultValue:0)}
			set { try!_reader.set(_objectOffset, propertyIndex: 3, value: newValue)}
		}

		public var createEagerVersion : FooBar? { return FooBar.create(_reader, objectOffset: _objectOffset) }
		
		public var hashValue: Int { return Int(_objectOffset) }
	}
}

public func ==(t1 : FooBar.LazyAccess, t2 : FooBar.LazyAccess) -> Bool {
	return t1._objectOffset == t2._objectOffset && t1._reader === t2._reader
}

extension FooBar {
    public struct Fast : Hashable {
        private var buffer : UnsafePointer<UInt8>? = nil
        private var myOffset : Offset = 0
        public init(buffer: UnsafePointer<UInt8>, myOffset: Offset){
            self.buffer = buffer
            self.myOffset = myOffset
        }
        public var sibling : Bar? { 
            get { return FlatBufferReaderFast.get(buffer, myOffset, propertyIndex: 0)}
            set { 
                if let newValue = newValue {
                    try!FlatBufferReaderFast.set(UnsafeMutablePointer<UInt8>(buffer), myOffset, propertyIndex: 0, value: newValue)
                }
            }
        }
        public var name : UnsafeBufferPointer<UInt8>? { get { return FlatBufferReaderFast.getStringBuffer(buffer, FlatBufferReaderFast.getOffset(buffer, myOffset, propertyIndex:1)) } }
        public var rating : Float64 { 
            get { return FlatBufferReaderFast.get(buffer, myOffset, propertyIndex: 2, defaultValue: 0) }
            set { try!FlatBufferReaderFast.set(UnsafeMutablePointer<UInt8>(buffer), myOffset, propertyIndex: 2, value: newValue) }
        }
        public var postfix : UInt8 { 
            get { return FlatBufferReaderFast.get(buffer, myOffset, propertyIndex: 3, defaultValue: 0) }
            set { try!FlatBufferReaderFast.set(UnsafeMutablePointer<UInt8>(buffer), myOffset, propertyIndex: 3, value: newValue) }
        }
        public var hashValue: Int { return Int(myOffset) }
    }
}

public func ==(t1 : FooBar.Fast, t2 : FooBar.Fast) -> Bool {
	return t1.buffer == t2.buffer && t1.myOffset == t2.myOffset
}

public extension FooBar {
	private func addToByteArray(_ builder : FlatBufferBuilder) -> Offset {
		if builder.config.uniqueTables {
			if let myOffset = builder.cache[ObjectIdentifier(self)] {
				return myOffset
			}
		}
		// let offset1 = try! builder.createString(name)
		var offset1 : Offset
		if let s = name_b {
			offset1 = try! builder.createString(s)
		} else if let s = name_ss {
			offset1 = try! builder.createStaticString(s)
		} else {
			offset1 = try! builder.createString(name)
		}
		try! builder.openObject(4)
		try! builder.addPropertyToOpenObject(3, value : postfix, defaultValue : 0)
		try! builder.addPropertyToOpenObject(2, value : rating, defaultValue : 0)
		try! builder.addPropertyOffsetToOpenObject(1, offset: offset1)
		if let sibling = sibling {
			builder.put(sibling)
			try! builder.addCurrentOffsetAsPropertyToOpenObject(0)
		}
		let myOffset =  try! builder.closeObject()
		if builder.config.uniqueTables {
			builder.cache[ObjectIdentifier(self)] = myOffset
		}
		return myOffset
	}
}

extension FooBar {
	public func toJSON() -> String{
		var properties : [String] = []
		if let sibling = sibling{
			properties.append("\"sibling\":\(sibling.toJSON())")
		}
		if let name = name{
			properties.append("\"name\":\"\(name)\"")
		}
		properties.append("\"rating\":\(rating)")
		properties.append("\"postfix\":\(postfix)")
		
		return "{\(properties.joined(separator: ","))}"
	}

	public static func fromJSON(_ dict : NSDictionary) -> FooBar {
		let result = FooBar()
		if let sibling = dict["sibling"] as? NSDictionary {
			result.sibling = Bar.fromJSON(sibling)
		}
		if let name = dict["name"] as? NSString {
			result.name = name as String
		}
		if let rating = dict["rating"] as? NSNumber {
			result.rating = rating.doubleValue
		}
		if let postfix = dict["postfix"] as? NSNumber {
			result.postfix = postfix.uint8Value
		}
		return result
	}
	
	public func jsonTypeName() -> String {
		return "\"FooBar\""
	}
}

public final class FooBarContainer {
	public static var instancePoolMutex : pthread_mutex_t = FooBarContainer.setupInstancePoolMutex()
	public static var maxInstanceCacheSize : UInt = 0
	public static var instancePool : ContiguousArray<FooBarContainer> = []
	public var list : ContiguousArray<FooBar?> = []
	public var initialized : Bool = false
	public var fruit : Enum? = Enum.apples
	public var location : String? {
		get {
			if let s = location_s {
				return s
			}
			if let s = location_ss {
				location_s = String(s)
			}
			if let s = location_b {
				location_s = String.init(bytesNoCopy: UnsafeMutablePointer<UInt8>(s.baseAddress!), length: s.count, encoding: String.Encoding.utf8, freeWhenDone: false)
			}
			return location_s
		}
		set {
			location_s = newValue
			location_ss = nil
			location_b = nil
		}
	}
	public func locationStaticString(_ newValue : StaticString) {
		location_ss = newValue
		location_s = nil
		location_b = nil
	}
	private var location_b : UnsafeBufferPointer<UInt8>? = nil
	public var locationBuffer : UnsafeBufferPointer<UInt8>? {return location_b}
	private var location_s : String? = nil
	private var location_ss : StaticString? = nil
	
	public init(){}
	public init(list: ContiguousArray<FooBar?>, initialized: Bool, fruit: Enum?, location: String?){
		self.list = list
		self.initialized = initialized
		self.fruit = fruit
		self.location_s = location
	}
	public init(list: ContiguousArray<FooBar?>, initialized: Bool, fruit: Enum?, location: StaticString?){
		self.list = list
		self.initialized = initialized
		self.fruit = fruit
		self.location_ss = location
	}
}

extension FooBarContainer : PoolableInstances {
	public func reset() { 
		while (list.count > 0) {
			var x = list.removeLast()!
			FooBar.reuseInstance(&x)
		}
		initialized = false
		fruit = Enum.apples
		location = nil
	}
}

public extension FooBarContainer {
	private static func create(_ reader : FlatBufferReader, objectOffset : Offset?) -> FooBarContainer? {
		guard let objectOffset = objectOffset else {
			return nil
		}
		if reader.config.uniqueTables {
			if let o = reader.objectPool[objectOffset]{
				return o as? FooBarContainer
			}
		}
		let _result = FooBarContainer.createInstance()
		if reader.config.uniqueTables {
			reader.objectPool[objectOffset] = _result
		}
		let offset_list : Offset? = reader.getOffset(objectOffset, propertyIndex: 0)
		let length_list = reader.getVectorLength(offset_list)
		if(length_list > 0){
			var index = 0
			_result.list.reserveCapacity(length_list)
			while index < length_list {
				_result.list.append(FooBar.create(reader, objectOffset: reader.getVectorOffsetElement(offset_list!, index: index)))
				index += 1
			}
		}
		_result.initialized = reader.get(objectOffset, propertyIndex: 1, defaultValue: false)
		_result.fruit = Enum(rawValue: reader.get(objectOffset, propertyIndex: 2, defaultValue: Enum.Apples.rawValue))
		_result.location_b = reader.getStringBuffer(reader.getOffset(objectOffset, propertyIndex: 3))
		return _result
	}
}

public extension FooBarContainer {
	public static func fromByteArray(_ data : UnsafeBufferPointer<UInt8>, config : BinaryReadConfig = BinaryReadConfig()) -> FooBarContainer {
		let reader = FlatBufferReader.create(data, config: config)
		let objectOffset = reader.rootObjectOffset
		let result = create(reader, objectOffset : objectOffset)!
		FlatBufferReader.reuse(reader)
		return result
	}
	public static func fromRawMemory(_ data : UnsafeMutablePointer<UInt8>, count : Int, config : BinaryReadConfig = BinaryReadConfig()) -> FooBarContainer {
		let reader = FlatBufferReader.create(data, count: count, config: config)
		let objectOffset = reader.rootObjectOffset
		let result = create(reader, objectOffset : objectOffset)!
		FlatBufferReader.reuse(reader)
		return result
	}
	public static func fromFlatBufferReader(_ flatBufferReader : FlatBufferReader) -> FooBarContainer {
		return create(flatBufferReader, objectOffset : flatBufferReader.rootObjectOffset)!
	}
}

public extension FooBarContainer {
	public func toByteArray (_ config : BinaryBuildConfig = BinaryBuildConfig()) -> [UInt8] {
		let builder = FlatBufferBuilder.create(config)
		let offset = addToByteArray(builder)
		performLateBindings(builder)
		try! builder.finish(offset, fileIdentifier: nil)
		let result = builder.data
		FlatBufferBuilder.reuse(builder)
		return result
	}
}

public extension FooBarContainer {
	public func toFlatBufferBuilder (_ builder : FlatBufferBuilder) -> Void {
		let offset = addToByteArray(builder)
		performLateBindings(builder)
		try! builder.finish(offset, fileIdentifier: nil)
	}
}

public extension FooBarContainer {
	public final class LazyAccess : Hashable {
		private let _reader : FlatBufferReader!
		private let _objectOffset : Offset!
		public init(data : UnsafeBufferPointer<UInt8>, config : BinaryReadConfig = BinaryReadConfig()){
			_reader = FlatBufferReader.create(data, config: config)
			_objectOffset = _reader.rootObjectOffset
		}
		deinit{
			FlatBufferReader.reuse(_reader)
		}
		public var data : [UInt8] {
			return _reader.data
		}
		private init?(reader : FlatBufferReader, objectOffset : Offset?){
			guard let objectOffset = objectOffset else {
				_reader = nil
				_objectOffset = nil
				return nil
			}
			_reader = reader
			_objectOffset = objectOffset
		}

		public lazy var list : LazyVector<FooBar.LazyAccess> = { [self]
			let vectorOffset : Offset? = self._reader.getOffset(self._objectOffset, propertyIndex: 0)
			let vectorLength = self._reader.getVectorLength(vectorOffset)
			let reader = self._reader
			return LazyVector(count: vectorLength){ [reader] in
				FooBar.LazyAccess(reader: reader, objectOffset : reader.getVectorOffsetElement(vectorOffset!, index: $0))
			}
		}()
		public var initialized : Bool { 
			get { return _reader.get(_objectOffset, propertyIndex: 1, defaultValue:false)}
			set { try!_reader.set(_objectOffset, propertyIndex: 1, value: newValue)}
		}
		public var fruit : Enum? { 
			get { return Enum(rawValue: _reader.get(self._objectOffset, propertyIndex: 2, defaultValue:Enum.Apples.rawValue))}
			set { 
				if let value = newValue{
					try!_reader.set(_objectOffset, propertyIndex: 2, value: value.rawValue)
				}
			}
		}
		public lazy var location : String? = self._reader.getString(self._reader.getOffset(self._objectOffset, propertyIndex: 3))

		public var createEagerVersion : FooBarContainer? { return FooBarContainer.create(_reader, objectOffset: _objectOffset) }
		
		public var hashValue: Int { return Int(_objectOffset) }
	}
}

public func ==(t1 : FooBarContainer.LazyAccess, t2 : FooBarContainer.LazyAccess) -> Bool {
	return t1._objectOffset == t2._objectOffset && t1._reader === t2._reader
}

extension FooBarContainer {
    public struct Fast : Hashable {
        private var buffer : UnsafePointer<UInt8>? = nil
        private var myOffset : Offset = 0
        public init(buffer: UnsafePointer<UInt8>, myOffset: Offset){
            self.buffer = buffer
            self.myOffset = myOffset
        }
        public init(_ data : UnsafePointer<UInt8>) {
            self.buffer = data
            self.myOffset = UnsafePointer<Offset>(buffer.advancedBy(0)).memory
        }
        public func getData() -> UnsafePointer<UInt8> {
            return buffer!
        }
        public struct ListVector {
            private var buffer : UnsafePointer<UInt8>? = nil
            private var myOffset : Offset = 0
            private let offsetList : Offset?
            private init(buffer b: UnsafePointer<UInt8>, myOffset o: Offset ) {
                buffer = b
                myOffset = o
                offsetList = FlatBufferReaderFast.getOffset(buffer, myOffset, propertyIndex: 0)
            }
            public var count : Int { get { return FlatBufferReaderFast.getVectorLength(buffer, offsetList) } }
            public subscript (index : Int) -> FooBar.Fast? {
                get {
                    if let ofs = FlatBufferReaderFast.getVectorOffsetElement(buffer, offsetList!, index: index) {
                        return FooBar.Fast(buffer: buffer, myOffset: ofs)
                    }
                    return nil
                }
            }
        }
        public lazy var list : ListVector = ListVector(buffer: self.buffer, myOffset: self.myOffset)
        public var initialized : Bool { 
            get { return FlatBufferReaderFast.get(buffer, myOffset, propertyIndex: 1, defaultValue: false) }
            set { try!FlatBufferReaderFast.set(UnsafeMutablePointer<UInt8>(buffer), myOffset, propertyIndex: 1, value: newValue) }
        }
        public var fruit : Enum? { 
            get { return Enum(rawValue: FlatBufferReaderFast.get(buffer, myOffset, propertyIndex: 2, defaultValue: Enum.Apples.rawValue)) }
            set {
                if let newValue = newValue {
                    try!FlatBufferReaderFast.set(UnsafeMutablePointer<UInt8>(buffer), myOffset, propertyIndex: 2, value: newValue.rawValue)
                }
            }
        }
        public var location : UnsafeBufferPointer<UInt8>? { get { return FlatBufferReaderFast.getStringBuffer(buffer, FlatBufferReaderFast.getOffset(buffer, myOffset, propertyIndex:3)) } }
        public var hashValue: Int { return Int(myOffset) }
    }
}

public func ==(t1 : FooBarContainer.Fast, t2 : FooBarContainer.Fast) -> Bool {
	return t1.buffer == t2.buffer && t1.myOffset == t2.myOffset
}

public extension FooBarContainer {
	private func addToByteArray(_ builder : FlatBufferBuilder) -> Offset {
		if builder.config.uniqueTables {
			if let myOffset = builder.cache[ObjectIdentifier(self)] {
				return myOffset
			}
		}
		// let offset3 = try! builder.createString(location)
		var offset3 : Offset
		if let s = location_b {
			offset3 = try! builder.createString(s)
		} else if let s = location_ss {
			offset3 = try! builder.createStaticString(s)
		} else {
			offset3 = try! builder.createString(location)
		}
		var offset0 = Offset(0)
		if list.count > 0{
			var offsets = [Offset?](count: list.count, repeatedValue: nil)
			var index = list.count - 1
			while(index >= 0){
				offsets[index] = list[index]?.addToByteArray(builder)
				index -= 1
			}
			try! builder.startVector(list.count, elementSize: strideof(Offset))
			index = list.count - 1
			while(index >= 0){
				try! builder.putOffset(offsets[index])
				index -= 1
			}
			offset0 = builder.endVector()
		}
		try! builder.openObject(4)
		try! builder.addPropertyOffsetToOpenObject(3, offset: offset3)
		try! builder.addPropertyToOpenObject(2, value : fruit!.rawValue, defaultValue : 0)
		try! builder.addPropertyToOpenObject(1, value : initialized, defaultValue : false)
		if list.count > 0 {
			try! builder.addPropertyOffsetToOpenObject(0, offset: offset0)
		}
		let myOffset =  try! builder.closeObject()
		if builder.config.uniqueTables {
			builder.cache[ObjectIdentifier(self)] = myOffset
		}
		return myOffset
	}
}

extension FooBarContainer {
	public func toJSON() -> String{
		var properties : [String] = []
		properties.append("\"list\":[\(list.map({$0 == nil ? "null" : $0!.toJSON()}).joined(separator: ","))]")
		properties.append("\"initialized\":\(initialized)")
		if let fruit = fruit{
			properties.append("\"fruit\":\(fruit.toJSON())")
		}
		if let location = location{
			properties.append("\"location\":\"\(location)\"")
		}
		
		return "{\(properties.joined(separator: ","))}"
	}

	public static func fromJSON(_ dict : NSDictionary) -> FooBarContainer {
		let result = FooBarContainer()
		if let list = dict["list"] as? NSArray {
			result.list = ContiguousArray(list.map({
				if let entry = $0 as? NSDictionary {
					return FooBar.fromJSON(entry)
				}
				return nil
			}))
		}
		if let initialized = dict["initialized"] as? NSNumber {
			result.initialized = initialized.boolValue
		}
		if let fruit = dict["fruit"] as? NSString {
			result.fruit = Enum.fromJSON(fruit as String)
		}
		if let location = dict["location"] as? NSString {
			result.location = location as String
		}
		return result
	}
	
	public func jsonTypeName() -> String {
		return "\"FooBarContainer\""
	}
}

private func performLateBindings(_ builder : FlatBufferBuilder) {
	for binding in builder.deferedBindings {
		switch binding.object {
		case let object as FooBar: try! builder.replaceOffset(object.addToByteArray(builder), atCursor: binding.cursor)
		case let object as FooBarContainer: try! builder.replaceOffset(object.addToByteArray(builder), atCursor: binding.cursor)
		default: continue
		}
	}
}
