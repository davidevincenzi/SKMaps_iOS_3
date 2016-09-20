//
//  MapRegion.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

enum MapRegionType: Int32
{
    case MapRegionTypeCity = 0
    case MapRegionTypeState
    case MapRegionTypeCountry
    case MapRegionTypeContinent
};

class MapRegion {
    
    var code: String!
    var name: String!
    var type: MapRegionType!
    var mapURL: String!
    var nbURL: String!
    var textureURL: String!
    var parentCode: String!
    var childRegions: Array<MapRegion>!
    var boundingBox: SKBoundingBox!
    
    init () {
        childRegions = Array<MapRegion>()
    }
    
    func isEqual(other: AnyObject) -> Bool {
        if (other as! MapRegion).code == code {
            return true
        }
        
        return false
    }
}
