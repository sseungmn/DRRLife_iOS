import Foundation

struct ORResponse: Decodable {
    let distance: Double
    let duration: Double
    let coordinates: [[Double]]
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootContainerKeys.self)
        var featuresContainer = try rootContainer.nestedUnkeyedContainer(forKey: .features)
        let featureContainer = try featuresContainer.nestedContainer(keyedBy: FeatureKeys.self)
        
        // root > features > geometry
        let geometryConatiner = try featureContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .geometry)
        self.coordinates = try geometryConatiner.decode([[Double]].self, forKey: .coordinates)
        
        // root > features > properties
        let propertiesContainer = try featureContainer.nestedContainer(keyedBy: PropertiesKeys.self.self, forKey: .properties)
        let summaryContainer = try propertiesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .summary)
        self.duration = try summaryContainer.decode(Double.self, forKey: .duration)
        self.distance = try summaryContainer.decode(Double.self, forKey: .distance)
    }

    private enum CodingKeys: String, CodingKey {
        case distance
        case duration
        case coordinates
    }

    private enum RootContainerKeys: CodingKey {
        case features
    }

    private enum FeatureKeys: CodingKey {
        case properties
        case geometry
    }
    
    private enum PropertiesKeys: CodingKey {
        case summary
    }
    
}
