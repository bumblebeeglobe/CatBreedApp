//
//  CatBreedViewModel.swift
//  RxSwiftApp
//
//  Created by N5747 on 03/03/2025.
//

import Foundation
import RxSwift
import RxCocoa

class CatBreedViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let allBreeds: [CatBreed] = [
        CatBreed(name: "Abyssinian", description: "Active and playful.", imageUrl: "https://tinyurl.com/5n6evk8e"),
        CatBreed(name: "Bengal", description: "Energetic and intelligent.", imageUrl: "https://tinyurl.com/mppfphf9"),
        CatBreed(name: "Birman", description: "Gentle and affectionate.", imageUrl: "https://tinyurl.com/5n6vcrbs"),
        CatBreed(name: "Burmese", description: "Uniquely social and playful temperament.", imageUrl: "https://tinyurl.com/55b73tky"),
        CatBreed(name: "Maine Coon", description: "Large and friendly.", imageUrl: "https://tinyurl.com/2sd4723v"),
        CatBreed(name: "Persian", description: "Quiet and docile.", imageUrl: "https://tinyurl.com/4hmmuuek"),
        CatBreed(name: "Ragdoll", description: "Large and weighty.", imageUrl: "https://tinyurl.com/ye233bj7"),
        CatBreed(name: "Russian Blue", description: "Medium-sized, intelligent, and graceful.", imageUrl: "https://tinyurl.com/mtvxz24d"),
        CatBreed(name: "Siamese", description: "Vocal and social.", imageUrl: "https://tinyurl.com/2hppkacs"),
        CatBreed(name: "Sphynx", description: "Hairless and affectionate.", imageUrl: "https://tinyurl.com/rvjveu8k")
    ]
    
    var filteredBreeds: BehaviorRelay<[CatBreed]> = BehaviorRelay(value: [])
    var favoriteBreeds: BehaviorRelay<[CatBreed]> = BehaviorRelay(value: [])
    var isSearching: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let searchText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var navigateToDetails: PublishSubject<CatBreed> = PublishSubject()
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        searchText
            .asObservable()
            .map { [weak self] query in
                guard let self = self else { return [] }
                return self.filteredBreedsList(for: query)
            }
            .distinctUntilChanged()
            .bind(to: filteredBreeds)
            .disposed(by: disposeBag)
    }
    
    private func filteredBreedsList(for query: String) -> [CatBreed] {
        if query.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
    }
    
    func selectBreed(_ breed: CatBreed) {
        navigateToDetails.onNext(breed)
    }
    
    func setSearchQuery(_ query: String) {
        searchText.accept(query)
    }
    
    func toggleSearchUI(isSearching: Bool) {
        isSearching ? filteredBreeds.accept(filteredBreeds.value) : filteredBreeds.accept(allBreeds)
    }
}

