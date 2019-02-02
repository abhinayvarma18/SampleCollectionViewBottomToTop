//
//  ReverseCollectionViewLayout.swift
//  3x3Connect
//
//  Created by abhinay varma on 29/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation
import UIKit

class ReverseCollectionViewLayout:UICollectionViewFlowLayout {
    var expandContentSizeToBounds:Bool?
    var minimumContentSizeHeight:CGFloat?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if (self.expandContentSizeToBounds != nil) {
            self.expandContentSizeToBounds = true
            self.minimumContentSizeHeight = nil
        }
    }
    
    override init() {
        super.init()
        if self.expandContentSizeToBounds != nil {
            self.expandContentSizeToBounds = true
            self.minimumContentSizeHeight = nil
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if ((self.expandContentSizeToBounds ?? false) &&
            fabsf(Float((self.collectionView?.bounds.size.height ?? 0.0) - newBounds.size.height)) > Float.ulpOfOne ) {
            return true
        }
        else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
    }
    
    func collectionViewContentSize() -> (CGSize) {
        var expandedSize:CGSize = super.collectionViewContentSize
        if (self.expandContentSizeToBounds != nil) {
            expandedSize.height = max(expandedSize.height, (self.collectionView?.bounds.size.height) ?? 0.0)
        }
        
        if (self.minimumContentSizeHeight != nil) {
            expandedSize.height = max(expandedSize.height, self.minimumContentSizeHeight ?? 0.0)
        }
        
        return expandedSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = super.layoutAttributesForItem(at: indexPath)!
        self.modifyLayoutAttribute(attribute)
        return attribute
    }
    
    override func layoutAttributesForElements(in reversedRect: CGRect) -> ([UICollectionViewLayoutAttributes]?) {
        let normalRect:CGRect = self.normalRectForReversedRect(reversedRect)
        let attributes:[UICollectionViewLayoutAttributes]? = super.layoutAttributesForElements(in: normalRect)
        var result:[UICollectionViewLayoutAttributes] = []
        for attribute in attributes ?? [] {
            let attr = attribute
            self.modifyLayoutAttribute(attr)
            result.append(attr)
        }
        return result
    }
    
    func setScrollDirection(_ scrollDirection:UICollectionViewScrollDirection) {
        assert(scrollDirection == UICollectionViewScrollDirection.vertical ,
               "horizontal scrolling is not supported")
        super.scrollDirection = scrollDirection
    }
    
    
    //MARK: Helpers
    func modifyLayoutAttribute(_ attribute:UICollectionViewLayoutAttributes) {
        let normalCenter:CGPoint = attribute.center
        let reversedCenter:CGPoint = self.reversedPointForNormalPoint(normalCenter)
        attribute.center = reversedCenter
    }
  
    /// Returns the reversed-layout rect corresponding to the normal-layout rect
    func reversedRectForNormalRect(_ normalRect:CGRect) -> CGRect {
        let size:CGSize = normalRect.size
        let normalTopLeft:CGPoint = normalRect.origin
        let reversedBottomLeft:CGPoint = self.reversedPointForNormalPoint(normalTopLeft)
        let reversedTopLeft:CGPoint = CGPoint(x: reversedBottomLeft.x - size.width, y: reversedBottomLeft.y - size.height)
        let reversedRect:CGRect = CGRect(x: reversedTopLeft.x, y: reversedTopLeft.y, width: size.width, height: size.height)
        return reversedRect
    }
    
    func reversedPointForNormalPoint(_ normalPoint:CGPoint) -> (CGPoint)
    {
        return CGPoint(x: self.reverseXforNormalX(normalPoint.x), y: self.reversedYforNormalY(normalPoint.y))
    }
    
    func normalRectForReversedRect(_ reversedRect:CGRect) -> CGRect {
        // reflection is its own inverse
        return self.reversedRectForNormalRect(reversedRect)
    }
 
    
    // y transforms
    /// Returns the reversed-layout y-offset, corresponding the normal-layout y-offset
    func reversedYforNormalY(_ normalY:CGFloat) -> CGFloat {
        let YreversedAroundContentSizeCenter:CGFloat = self.collectionViewContentSize.height - normalY
        return YreversedAroundContentSizeCenter
    }
    
    // x transforms
    /// Returns the reversed-layout x-offset, corresponding the normal-layout x-offset
    func reverseXforNormalX(_ normalX:CGFloat) -> CGFloat {
        let XreversedAroundContentSizeCenter:CGFloat = self.collectionViewContentSize.width - normalX
        return XreversedAroundContentSizeCenter
    }
}


