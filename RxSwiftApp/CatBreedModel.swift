//
//  CatBreedModel.swift
//  RxSwiftApp
//
//  Created by N5747 on 03/03/2025.
//

struct CatBreed: Codable, Equatable {
    let name: String
    let description: String
    let imageUrl: String
    var isExpanded: Bool = false
    
    static func == (lhs: CatBreed, rhs: CatBreed) -> Bool {
        return lhs.name == rhs.name
    }
}
