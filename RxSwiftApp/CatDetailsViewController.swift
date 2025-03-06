//
//  CatDetailsViewController.swift
//  RxSwiftApp
//
//  Created by N5747 on 03/03/2025.
//

import UIKit
import RxSwift
import RxCocoa

class CatDetailsViewController: UIViewController {
    var catBreedRelay = BehaviorRelay<CatBreed?>(value: nil)
    private let disposeBag = DisposeBag()
    private let imageUrlSubject = PublishSubject<String>()
    private var isFavorite = BehaviorRelay<Bool>(value: false)
    let blurCondition = BehaviorSubject<Bool>(value: false)
    @IBOutlet weak var imgCat: UIImageView!
    @IBOutlet weak var lblCatName: UILabel!
    @IBOutlet weak var lblCatDescription: UILabel!
    @IBOutlet weak var imgFav: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupFavoriteGesture()
    }
    
    private func setupBindings() {
        catBreedRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] breed in
                self?.configureView(with: breed)
            })
            .disposed(by: disposeBag)
        
        imageUrlSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] urlString in
                self?.loadImage(from: urlString)
            })
            .disposed(by: disposeBag)
        
        isFavorite
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFav in
                self?.updateFavoriteIcon(isFav)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupFavoriteGesture() {
        imgFav.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        imgFav.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map { [weak self] _ in !(self?.isFavorite.value ?? false) }
            .do(onNext: { [weak self] newValue in
                self?.toggleFavoriteStatus(newValue)
            })
            .bind(to: isFavorite)
            .disposed(by: disposeBag)
    }
    
    private func configureView(with breed: CatBreed) {
        lblCatName.text = breed.name
        lblCatDescription.text = breed.description
        imageUrlSubject.onNext(breed.imageUrl)
        isFavorite.accept(UserDefaults.standard.loadFavorites().contains(breed))
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            imgCat.image = cachedImage
            
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imgCat.image = image
                    self.imgCat.applyBlurEffect()
                    ImageCache.shared.setImage(image, forKey: urlString)
                }
            }
        }
    }
    
    private func toggleFavoriteStatus(_ isFav: Bool) {
        guard let breed = catBreedRelay.value else { return }
        var favorites = UserDefaults.standard.loadFavorites()
        
        if isFav {
            favorites.append(breed)
        } else {
            favorites.removeAll { $0 == breed }
        }
        
        UserDefaults.standard.saveFavorites(favorites)
    }
    
    private func updateFavoriteIcon(_ isFav: Bool) {
        imgFav.image = UIImage(systemName: isFav ? "heart.fill" : "heart")
    }
    
    @IBAction func actBack(_ sender: Any) {
        dismiss(animated: true)
    }
}

