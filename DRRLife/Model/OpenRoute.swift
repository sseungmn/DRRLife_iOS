import Foundation
import Moya
// MARK: - OpenRoute Request
enum ORRequest0 {
    static private let key = Bundle.main.Openroute
    
    case cycling_regular(start: Coordinate, end: Coordinate)
    case cycling_road(start: Coordinate, end: Coordinate)
    case cycling_electric(start: Coordinate, end: Coordinate)
    case foot_walking(start: Coordinate, end: Coordinate)
}

extension ORRequest0: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.openrouteservice.org/v2/directions")!
    }
    var path: String {
        switch self {
        case .cycling_regular:
            return "/cycling_regular"
        case .cycling_road:
            return "/cycling_road"
        case .cycling_electric:
            return "/cycling_electric"
        case .foot_walking:
            return "/foot_walking"
        }
    }
    var method: Moya.Method {
        switch self {
        case .cycling_regular:
            return .get
        case .cycling_road:
            return .get
        case .cycling_electric:
            return .get
        case .foot_walking:
            return .get
        }
    }
    var task: Task {
        var parameters: [String: Any] = [
            "api_key": ORRequest0.key,
            "start": "",
            "end": ""
        ]
        switch self {
        case .cycling_regular(let start, let end):
            parameters["start"] = start
            parameters["end"] = end
        case .cycling_road(let start, let end):
            parameters["start"] = start
            parameters["end"] = end
        case .cycling_electric(let start, let end):
            parameters["start"] = start
            parameters["end"] = end
        case .foot_walking(let start, let end):
            parameters["start"] = start
            parameters["end"] = end
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - OpenRoute Response
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
