//
//  CatBreedCell.swift
//  RxSwiftApp
//
//  Created by N5747 on 03/03/2025.
//
import UIKit

class CatCvCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowToImageView()
    }
    
    func configure(with breed: CatBreed) {
        lblTitle.text = breed.name
        img.loadImage(from: breed.imageUrl)
        
    }
    private func addShadowToImageView() {
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.contentView.layer.shadowOpacity = 0.5
        self.contentView.layer.shadowRadius = 4
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.cornerRadius = 8
    }
}

class CatBreedTvCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    func configure(with breed: CatBreed) {
        lblTitle.text = breed.name
        lblDescription.text = breed.description
        img.loadImage(from: breed.imageUrl)
    }
}

class CatBreedFavTvCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    func configure(with breed: CatBreed) {
        lblTitle.text = breed.name
        lblDescription.text = breed.description
        img.loadImage(from: breed.imageUrl)
    }
}
