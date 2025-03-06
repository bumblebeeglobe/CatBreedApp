//
//  ViewController.swift
//  RxSwiftApp
//
//  Created by N5747 on 28/02/2025.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

class ViewController: UIViewController {
    @IBOutlet weak var lblPageTitle: UILabel!
    @IBOutlet weak var searchTxtView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tvSearchResult: UITableView!
    @IBOutlet weak var cvCatBreed: UICollectionView!
    @IBOutlet weak var tvFavorite: UITableView!
    @IBOutlet weak var favoriteView: UIView!
    
    private let disposeBag = DisposeBag()
    private let viewModel = CatBreedViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.favoriteBreeds.accept(UserDefaults.standard.loadFavorites())
    }
    
    private func setupUI() {
        lblPageTitle.text = "Home"
        txtSearch.placeholder = "Search Cat Breed"
        cvCatBreed.backgroundColor = .clear
        tvFavorite.allowsSelectionDuringEditing = true
        favoriteView.layer.cornerRadius = 8
    }
    
    private func setupBindings() {
        viewModel.favoriteBreeds.accept(UserDefaults.standard.loadFavorites())
        
        txtSearch.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        txtSearch.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in self?.toggleSearchUI(isSearching: true) })
            .disposed(by: disposeBag)
        
        txtSearch.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in self?.toggleSearchUI(isSearching: false) })
            .disposed(by: disposeBag)
        
        viewModel.filteredBreeds
            .bind(to: tvSearchResult.rx.items(cellIdentifier: "CatBreedTvCell", cellType: CatBreedTvCell.self)) { _, breed, cell in
                cell.configure(with: breed)
            }
            .disposed(by: disposeBag)
        
        viewModel.filteredBreeds
            .bind(to: cvCatBreed.rx.items(cellIdentifier: "CatCvCell", cellType: CatCvCell.self)) { _, breed, cell in
                cell.configure(with: breed)
            }
            .disposed(by: disposeBag)
        
        viewModel.favoriteBreeds
            .bind(to: tvFavorite.rx.items(cellIdentifier: "CatBreedFavTvCell", cellType: CatBreedFavTvCell.self)) { _, breed, cell in
                cell.configure(with: breed)
                self.favoriteView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        tvSearchResult.rx.modelSelected(CatBreed.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] breed in
                self?.viewModel.selectBreed(breed)
            })
            .disposed(by: disposeBag)
        
        cvCatBreed.rx.modelSelected(CatBreed.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] breed in
                self?.viewModel.selectBreed(breed)
            })
            .disposed(by: disposeBag)
        
        tvFavorite.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                var favorites = self.viewModel.favoriteBreeds.value
                favorites.remove(at: indexPath.row)
                self.viewModel.favoriteBreeds.accept(favorites)
                UserDefaults.standard.saveFavorites(favorites)
            })
            .disposed(by: disposeBag)
        
        viewModel.navigateToDetails
            .subscribe(onNext: { [weak self] breed in
                self?.navigateToCatDetails(breed: breed)
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleSearchUI(isSearching: Bool) {
        cvCatBreed.isHidden = isSearching
        tvSearchResult.isHidden = !isSearching
        favoriteView.isHidden = isSearching
    }
    
    private func navigateToCatDetails(breed: CatBreed) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let catDetailsVC = storyboard.instantiateViewController(withIdentifier: "CatDetailsViewController") as? CatDetailsViewController {
            catDetailsVC.catBreedRelay.accept(breed)
            catDetailsVC.modalPresentationStyle = .fullScreen
            self.present(catDetailsVC, animated: true, completion: nil)
        }
    }
}

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cachedImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                    ImageCache.shared.setImage(image, forKey: urlString)
                }
            }
        }
    }
    
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}

extension UserDefaults {
    private static let favoritesKey = "favoriteBreeds"
    
    func saveFavorites(_ breeds: [CatBreed]) {
        if let encoded = try? JSONEncoder().encode(breeds) {
            set(encoded, forKey: UserDefaults.favoritesKey)
        }
    }
    
    func loadFavorites() -> [CatBreed] {
        guard let data = data(forKey: UserDefaults.favoritesKey),
              let breeds = try? JSONDecoder().decode([CatBreed].self, from: data) else {
            return []
        }
        return breeds
    }
}

