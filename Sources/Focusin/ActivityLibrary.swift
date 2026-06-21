import Foundation

public enum ActivityLibrary {
    public static func load(bundle: Bundle = defaultBundle) throws -> [BreakActivity] {
        guard let url = bundle.url(forResource: "Activities", withExtension: "json") else {
            throw ActivityLibraryError.missingResource
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([BreakActivity].self, from: data)
    }

    public static var defaultBundle: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        .main
        #endif
    }
}

public enum ActivityLibraryError: Error {
    case missingResource
}
