//
//  Comparison+Utils.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


extension Double {
    var euroString: String {
        Int(self.rounded()).formatted(.currency(code: "EUR").precision(.fractionLength(0)))
    }

    var percentString: String {
        formatted(.percent.precision(.fractionLength(1)))
    }

    var signedEuroString: String {
        let sign = self >= 0 ? "+" : "-"
        return "\(sign)\(abs(self).euroString)"
    }

    var compactDecimalString: String {
        formatted(.number.precision(.fractionLength(3)))
    }
}
