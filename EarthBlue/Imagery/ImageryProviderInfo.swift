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
        return .init(title: "EPIC", description: """
EPIC (Earth Polychromatic Imaging Camera) is a 10-channel spectroradiometer (317 – 780 nm) onboard NOAA’s DSCOVR (Deep Space Climate Observatory) spacecraft. EPIC provides 10 narrow band spectral images of the entire sunlit face of Earth using a 2048x2048 pixel CCD (Charge Coupled Device) detector coupled to a 30-cm aperture Cassegrain telescope.

The DSCOVR spacecraft is located at the Earth-Sun Lagrange-1 (L-1) point giving EPIC a unique angular perspective that will be used in science applications to measure ozone, aerosols, cloud reflectivity, cloud height, vegetation properties, and UV radiation estimates at Earth's surface.
""", sourceURL: .init(string: "https://epic.gsfc.nasa.gov/about/epic")!)
    }
    
    
    static func makeCuriosityRoverInfo() -> ImageryProviderInfo {
        return .init(title: "Curiosity Rover", description: """
Part of NASA's Mars Science Laboratory mission, Curiosity is the largest and most capable rover ever sent to Mars. It launched Nov. 26, 2011 and landed on Mars at 10:32 p.m. PDT on Aug. 5, 2012 (1:32 a.m. EDT on Aug. 6, 2012).

Curiosity set out to answer the question: Did Mars ever have the right environmental conditions to support small life forms called microbes? Early in its mission, Curiosity's scientific tools found chemical and mineral evidence of past habitable environments on Mars. It continues to explore the rock record from a time when Mars could have been home to microbial life.
""", sourceURL: .init(string: "https://mars.nasa.gov/msl/mission/overview")!)
    }
}
