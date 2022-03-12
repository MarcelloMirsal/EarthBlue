//
//  ImageryProviderInfo.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 08/01/2022.
//

import Foundation

struct ImageryProviderInfo {
    let title: String
    let description: String
    let sourceURL: URL
}

struct ImageryProviderInfoFactory {
    static func makeEPICImageryProviderInfo() -> ImageryProviderInfo {
        return .init(title: "Earth Polychromatic Imaging Camera (EPIC)", description: NSLocalizedString("EPIC.ProviderInfo", comment: ""), sourceURL: .init(string: "https://epic.gsfc.nasa.gov/about/epic")!)
    }
    
    
    static func makeCuriosityRoverInfo() -> ImageryProviderInfo {
        return .init(title: "Curiosity Rover", description: NSLocalizedString("Curiosity.ProviderInfo", comment: ""), sourceURL: .init(string: "https://mars.nasa.gov/msl/mission/overview")!)
    }
    
    static func makeSpiritRoverInfo() -> ImageryProviderInfo {
        return .init(title: "Spirit Rover", description: NSLocalizedString("Spirit.ProviderInfo", comment: ""), sourceURL: .init(string: "https://www.jpl.nasa.gov/missions/mars-exploration-rover-spirit-mer-spirit")!)
    }
    
    static func makeOpportunityRoverInfo() -> ImageryProviderInfo {
        return .init(title: "Opportunity Rover", description: NSLocalizedString("Opportunity.ProviderInfo", comment: ""), sourceURL: .init(string: "https://www.jpl.nasa.gov/missions/mars-exploration-rover-opportunity-mer")!)
    }
}
