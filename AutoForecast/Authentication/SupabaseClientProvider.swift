//
//  SupabaseClientProvider.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Supabase

enum SupabaseClientProvider {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://mxfghxnyhrxsorxjztpz.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14ZmdoeG55aHJ4c29yeGp6dHB6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzOTczNDIsImV4cCI6MjA5ODk3MzM0Mn0.Xj5dURaQdObe5IwW2fRCF8bP0mJRGAhpqxG2VAFucyA",
        options: .init(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
