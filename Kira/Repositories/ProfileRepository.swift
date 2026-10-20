//
//  ProfileRepository.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 20/10/26.
//

import Supabase

class ProfileRepository {
  func insertProfile(_ profile: Profile) async throws {
    try await supabase
      .from("profiles")
      .insert(profile)
      .execute()
  }
}
