//
//  input.swift
//  Utils
//
//  Created by LEONID NIFANTIJEV on 08.12.2023.
//

import SwiftData
import SwiftUI

public extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" //"2023-11-23 07:18:16 +0000"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


public func readJsonFile(name: String, from bundle: Bundle = .main) -> Data? {
    let url: URL = bundle.url(forResource: name, withExtension: "json")!
    do {
        let jsonData = try Data(contentsOf: url)
        return jsonData
    }

    catch {
        print(error)
        return nil
    }
}


public extension ModelContext {
    
    func readFromDb<T: PersistentModel>() -> [T] {
        do {
            let fetchProductDescriptor = FetchDescriptor<T>()
            return try self.fetch(fetchProductDescriptor)
        } catch let error {
            debugPrint(error)
            return []
        }
    }
    
    func filterFromDb<T: PersistentModel>(predicate: Predicate<T>) -> [T] {
        do {
            let fetchProductDescriptor = FetchDescriptor<T>(predicate: predicate)
            return try self.fetch(fetchProductDescriptor)
        } catch let error {
            debugPrint(error)
            return []
        }
    }
}


public extension Double {
    var int: Int {
        Int(self)
    }
    
    var string: String {
        "\(self)"
    }
}

public extension String {
    var double: Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        if let value = numberFormatter.number(from: self)?.doubleValue {
            return value
        } else {
            assertionFailure("Impossible to convert string \(self) to double")
            return 0
        }
    }
    
    var int: Int {
        return (self as NSString).integerValue
    }
}

public extension Int {
    var string: String {
        return "\(self)"
    }

    var float: Float {
        Float(self)
    }
    
    var cgFloat: CGFloat {
        CGFloat(self)
    }
    
    var double: Double {
        Double(self)
    }
}


public extension View {
    var asViewController: UIViewController {
        UIHostingController(rootView: self)
    }
}
