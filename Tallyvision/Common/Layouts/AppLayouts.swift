//
//  AppLayouts.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 26. 11. 2024..
//

import Foundation
import UIKit

class AppLayouts {
    static let shared = AppLayouts()
   
    func episodesListSection() -> NSCollectionLayoutSection {
        let section = createSection(
            itemSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            groupSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(AppConstants.screenWidth / 3)),
            groupInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0),
            sectionInsets: NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        )
        
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func castSection() -> NSCollectionLayoutSection {
         let section = createSection(
            itemSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)),
            groupSize: NSCollectionLayoutSize(widthDimension: .absolute(90), heightDimension: .estimated(210)),
            groupInsets: NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 22, bottom: 70, trailing: 0),
            scrollingBehavior: .continuous,
            decorationElementKind: "backgroundDecoration"
        )
       
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
       
        return section
    }
    
    func metaDataSection() -> NSCollectionLayoutSection {
        let screenWidth = AppConstants.screenWidth
        let section = createSection(
            itemSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            groupSize: NSCollectionLayoutSize(widthDimension: .absolute(screenWidth), heightDimension: .absolute(AppConstants.screenHeight * 0.35))
        )
        
        let metadataSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: metadataSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
        ]
        
        return section
    }
    
    func showCardsSection() -> NSCollectionLayoutSection {
        let section = createSection(
            itemSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            groupSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(400)),
            sectionInsets: NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15),
            scrollingBehavior: .groupPagingCentered
        )
        section.interGroupSpacing = 10
        section.boundarySupplementaryItems = [createHeader()]
        
        return section
    }
    
    func posterSection() -> NSCollectionLayoutSection {
        let section = createSection(
            itemSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            groupSize: NSCollectionLayoutSize(
                widthDimension: .absolute(AppConstants.posterHeight / AppConstants.posterImageRatio),
                heightDimension: .absolute(AppConstants.posterHeight)
            ),
            groupInsets: NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5),
            sectionInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0),
            scrollingBehavior: .continuous
        )
        section.boundarySupplementaryItems = [createHeader()]
        
        return section
    }
   
    private func createSection(
            itemSize: NSCollectionLayoutSize,
            groupSize: NSCollectionLayoutSize,
            groupInsets: NSDirectionalEdgeInsets = .zero,
            sectionInsets: NSDirectionalEdgeInsets = .zero,
            scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none,
            decorationElementKind: String? = nil
    ) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = groupInsets
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        section.orthogonalScrollingBehavior = scrollingBehavior
        
        if let decorationElementKind = decorationElementKind {
            section.decorationItems = [
                NSCollectionLayoutDecorationItem.background(elementKind: decorationElementKind)
            ]
        }
        
        return section
    }
    
    private func createHeader(fractionalWidth: CGFloat = 0.95) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fractionalWidth),
            heightDimension: .estimated(40)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
