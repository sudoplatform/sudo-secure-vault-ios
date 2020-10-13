//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Data {

    /// Converts Data to HEX string.
    ///
    /// - Returns: HEX string representation of Data.
    func toHexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    /// Converts Data to JSON serializable object, e.g. Dictionary or Array.
    ///
    /// - Returns: Dictionary or Array representing JSON data. nil if the data
    ///     does not represent JSON.
    func toJSONObject() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers)
    }

    /// Converts JSON data to a pretty formatted string.
    ///
    /// - Return: Pretty formatted JSON string.
    func toJSONString() -> String? {
        guard let jsonObject = self.toJSONObject(),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let str = String(data: data, encoding: .utf8) else {
                return nil
        }

        return str
    }

    /// XOR this Data with another Data.
    ///
    /// - Parameter rhs: Data to XOR with.
    /// - Returns: XORed Data.
    public func xor(rhs: Data) throws -> Data {
        guard self.count == rhs.count else {
            throw SudoSecureVaultClientError.fatalError(description: "XOR inputs not identical in size.")
        }

        var data = Data(count: self.count)

        for i in 0..<self.count {
            data[i] = self[i] ^ rhs[i]
        }

        return data
    }

    /// Sets all bytes to the specified value.
    ///
    /// - Parameter byte: Byte value to set.
    public mutating func fill(byte: UInt8) {
        for i in self.indices {
            self[i] = byte
        }
    }

}
