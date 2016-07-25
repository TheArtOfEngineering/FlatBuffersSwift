//
//  FlatBuffersAPITest.swift
//  FlatBuffersSwift
//
//  Created by Maxim Zaks on 16.01.16.
//  Copyright © 2016 maxim.zaks. All rights reserved.
//

import XCTest
import FlatBuffersSwift

class FlatBuffersGeneratedAPITest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.birthday = Date()
        p1.birthday?.day = 12
        p1.birthday?.month = 6
        p1.birthday?.year = 1981
        
        p1.currentLoccation = GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12))
        p1.previousLocations = [GeoLocation(latitude: 1.5, longitude: 2.5, elevation: 3.5, s: S1(i:12)),GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12))]
        
        list.entries.append(p1)
        
        let p2 = Contact()
        p2.name = "Someone"
        
        list.entries.append(p2)
        
        XCTAssert(list.entries[0]?.birthday?.year == 1981)
        XCTAssert(list.entries[1]?.birthday?.year == nil)
        
        let data = list.toByteArray()
        
        let lazyList  = ContactList.LazyAccess(data: UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssert(lazyList.entries[0]?.name == "Max")
        XCTAssert(lazyList.entries[0]?.birthday?.year == 1981)
        XCTAssert(lazyList.entries[0]?.currentLoccation == GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12)))
        XCTAssert(lazyList.entries[0]?.previousLocations[1] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12)))
        XCTAssert(lazyList.entries[1]?.birthday?.year == nil)
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssert(eagerList.entries[0]?.name == "Max")
        XCTAssert(eagerList.entries[0]?.birthday?.year == 1981)
        XCTAssert(eagerList.entries[0]?.currentLoccation == GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12)))
        XCTAssert(eagerList.entries[0]?.previousLocations[1] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12)))
        XCTAssert(eagerList.entries[1]?.birthday?.year == nil)
    }
    
    func testWithFullMemmoryalignementAndNullTerminatedUTF8Example() {
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.birthday = Date()
        p1.birthday?.day = 12
        p1.birthday?.month = 6
        p1.birthday?.year = 1981
        
        p1.currentLoccation = GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12))
        p1.previousLocations = [GeoLocation(latitude: 1.5, longitude: 2.5, elevation: 3.5, s: S1(i:12)),GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12))]
        
        list.entries.append(p1)
        
        let p2 = Contact()
        p2.name = "Someone"
        
        list.entries.append(p2)
        
        XCTAssert(list.entries[0]?.birthday?.year == 1981)
        XCTAssert(list.entries[1]?.birthday?.year == nil)
        
        let config = BinaryBuildConfig(
            initialCapacity : 1,
            uniqueStrings : true,
            uniqueTables : true,
            uniqueVTables : true,
            forceDefaults : false,
            fullMemoryAlignment: true,
            nullTerminatedUTF8 : true
        )
        
        let data = list.toByteArray(config)
        
        
        let lazyList  = ContactList.LazyAccess(data: UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssertEqual(lazyList.entries[0]?.name, "Max")
        XCTAssert(lazyList.entries[0]?.birthday?.year == 1981)
        XCTAssert(lazyList.entries[0]?.currentLoccation == GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12)))
        XCTAssert(lazyList.entries[0]?.previousLocations[1] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12)))
        XCTAssert(lazyList.entries[1]?.birthday?.year == nil)
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssertEqual(eagerList.entries[0]?.name, "Max")
        XCTAssert(eagerList.entries[0]?.birthday?.year == 1981)
        XCTAssert(eagerList.entries[0]?.currentLoccation == GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12)))
        XCTAssert(eagerList.entries[0]?.previousLocations[1] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:12)))
        XCTAssert(eagerList.entries[1]?.birthday?.year == nil)
    }
    
    func testReplacingValuesInLazyInstances(){
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.birthday = Date()
        p1.birthday?.day = 12
        p1.birthday?.month = 6
        p1.birthday?.year = 1981
        p1.currentLoccation = GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12))
        
        list.entries = [p1]
        
        let data = list.toByteArray()
        
        let lazyList  = ContactList.LazyAccess(data: UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        lazyList.entries[0]?.gender = .Female
        lazyList.entries[0]?.birthday?.day = 15
        lazyList.entries[0]?.currentLoccation = GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13))
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(lazyList.data), count: lazyList.data.count))
        
        XCTAssert(eagerList.entries[0]?.currentLoccation == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13)))
        XCTAssert(eagerList.entries[0]?.gender == .Female)
        XCTAssert(eagerList.entries[0]?.birthday?.day == 15)
    }
    
    func testReplacingValuesInFastInstances(){
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.birthday = Date()
        p1.birthday?.day = 12
        p1.birthday?.month = 6
        p1.birthday?.year = 1981
        p1.currentLoccation = GeoLocation(latitude: 2.5, longitude: 3.5, elevation: 4.5, s: S1(i:12))
        
        list.entries = [p1]
        
        let data = list.toByteArray()
        
        var lazyList  = ContactList.Fast(data)
        var entry0 = lazyList.entries[0]!
        entry0.gender = .Female
        var birthday = entry0.birthday!
        birthday.day = 15
        entry0.currentLoccation = GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13))
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssert(eagerList.entries[0]?.currentLoccation == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13)))
        XCTAssert(eagerList.entries[0]?.gender == .Female)
        XCTAssert(eagerList.entries[0]?.birthday?.day == 15)
    }
    
    func testReplacingVectorValuesInLazyInstances(){
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.moods = [Mood.angry, Mood.funny]
        p1.previousLocations = [GeoLocation(latitude: 1.5, longitude: 2.5, elevation: 3.5, s: S1(i:2))]
        
        list.entries = [p1]
        
        let data = list.toByteArray()
        
        let lazyList  = ContactList.LazyAccess(data: UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        lazyList.entries[0]?.moods[0] = Mood.Serious
        lazyList.entries[0]?.previousLocations[0] = GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13))
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(lazyList.data), count: lazyList.data.count))
        
        XCTAssert(eagerList.entries[0]?.previousLocations[0] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13)))
        XCTAssert(eagerList.entries[0]?.moods[0] == Mood.Serious)
        XCTAssert(eagerList.entries[0]?.moods[1] == Mood.Funny)
    }
    
    func testReplacingVectorValuesInFastInstances(){
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.moods = [Mood.angry, Mood.funny]
        p1.previousLocations = [GeoLocation(latitude: 1.5, longitude: 2.5, elevation: 3.5, s: S1(i:2))]
        
        list.entries = [p1]
        
        let data = list.toByteArray()
        
        var lazyList  = ContactList.Fast(data)
        var entry0 = lazyList.entries[0]!
        entry0.moods[0] = Mood.Serious
        entry0.previousLocations[0] = GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13))
        
        let eagerList  = ContactList.fromByteArray(UnsafeBufferPointer<UInt8>(start: UnsafePointer(data), count: data.count))
        
        XCTAssert(eagerList.entries[0]?.previousLocations[0] == GeoLocation(latitude: 5.5, longitude: 6.5, elevation: 7.5, s: S1(i:13)))
        XCTAssert(eagerList.entries[0]?.moods[0] == Mood.Serious)
        XCTAssert(eagerList.entries[0]?.moods[1] == Mood.Funny)
    }
    
    func testJSONEncodingAndDecoding(){
        let list = ContactList()
        let p1 = Contact()
        p1.name = "Max"
        p1.gender = .male
        p1.moods = [Mood.angry, Mood.funny]
        p1.currentLoccation = GeoLocation(latitude: 3.5, longitude: 3.5, elevation: 3.5, s: S1(i:8))
        p1.previousLocations = [GeoLocation(latitude: 1.5, longitude: 2.5, elevation: 3.5, s: S1(i:2))]
        
        let postalAddres = PostalAddress(country: "DE", city: "BE", postalCode: 12345, streetAndNumber: "foo bar str. 45")
        p1.addressEntries = [AddressEntry(order: 0, address: postalAddres)]
        
        list.entries = [p1]
        
        let jsonString = list.toJSON()
        let json = try!JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: []) as! NSDictionary
        
        let newList  = ContactList.fromJSON(json)
        let newJsonString = newList.toJSON()
        XCTAssert(jsonString == newJsonString)
        
    }
}
