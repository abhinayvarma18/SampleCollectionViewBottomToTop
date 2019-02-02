//
//  Constants.swift
//  3x3Connect
//
//  Created by abhinay varma on 30/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let kSmallHeight:CGFloat = 150.0
    static let kMediumHeight:CGFloat = 250.0
    static let kBigHeight:CGFloat = 350.0
    
    static let numberOfSectionsInCollectionView:CGFloat = 2
    static let initialDataToLoad:Int = 10
    
    
    static let collectionViewCellNibName = "BottomRightToLeftCollectionViewCell"
    static let collectionViewCellIdentifier = "feedCell"
    
    static let collectionFooterNibName = "CollectionViewBottomFooter"
    static let collectionElementKindSectionFooter = "UICollectionElementKindSectionFooter"
    static let collectionFooterIdentifier = "footer"
}

struct FirebaseConstants {
    static let userNode:String = "users"
    static let storyDetailNode:String = "storyDetail"
    static let storyLikeNode:String = "storyLikes"
    static let storyIdString:String = "storyId"
}

struct ErrorResponse {
    static let dataBreached:String = "All data is been fetched,\n No Data available on server"
}
