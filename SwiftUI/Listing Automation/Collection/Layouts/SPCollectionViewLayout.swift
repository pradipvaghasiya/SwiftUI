//
//  SPCollectionViewLayout.swift
//  SwiftUIDemo
//
//  Created by Pradip Vaghasiya on 01/05/15.
//  Copyright (c) 2015 Happyfall. All rights reserved.
//

import UIKit

private let kDefaultSpacing : CGFloat = 5

open class SPCollectionViewLayout: UICollectionViewLayout {
    /// Denotes spacing between two lines incase of horizontal layout it is distance between columns and in vertical it is distance between rows.
    public final var lineSpacing: CGFloat = kDefaultSpacing
    
    /// Denotes spacing between two items incase of horizontal layout it is distance between rows and in vertical it is distance between columns.
    public final var interItemSpacing: CGFloat = kDefaultSpacing
    
    /// Denotes inset of that section
    public final var sectionInset: UIEdgeInsets = UIEdgeInsets.init(top: kDefaultSpacing, left: kDefaultSpacing, bottom: kDefaultSpacing, right: kDefaultSpacing)
    
    /// Denotes Attributes at given indexPath
    final var attributesDictionary : [IndexPath:UICollectionViewLayoutAttributes] = [:]
    
    /// Save content size of each Section
    final var sectionSizeDictionary : [Int :(width:CGFloat, height:CGFloat)] = [:]
    
    /// SPCollection View Delegate
    open weak var delegate : SPCollectionViewLayoutDelegate?
    
    /// Set as true if Pagination is needed. Default is false.
    open var pagingEnabled = false
    
    /// Set different kind of supplymentary views if any
    open var supplementaryViewKinds : [String] = []

    /// Set different kind of decoration views if any
    open var decorationViewKinds : [String] = []
    
    // MARK: Prepare Layout
    override open func prepare() {
        super.prepare()
        
        // Set decelerationRate as fast in case of pagination.
        if pagingEnabled{
            collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        }else{
            collectionView?.decelerationRate = UIScrollView.DecelerationRate.normal
        }
        
        // Clear all attribute and content size values
        attributesDictionary.removeAll(keepingCapacity: false)
        sectionSizeDictionary.removeAll(keepingCapacity: false)
        
        // Attribute Calculation
        self.calculateAttributesForAllItemsInCollectionView()
        
    }
    
    // MARK: Attributes Calculation
    ///Calculates attributes for all items. It iterates through all sections and items in that section.
    final func calculateAttributesForAllItemsInCollectionView(){
        // Check whether collectionview is nil, If yes simply return
        if self.collectionView == nil{
            return
        }
        
        // If no section no need to prepare return.
        let collectionView = self.collectionView!
        let noOfSections = collectionView.numberOfSections
        if noOfSections == 0 {
            return
        }
        
        for section in 0...(noOfSections - 1){
            
            let noOfItemsInCurrentSection = collectionView.numberOfItems(inSection: section)
            
            if noOfItemsInCurrentSection == 0{
                sectionSizeDictionary[section] = (0,0)
                // Update Section Size array
                continue
            }
            
            for item in 0...(noOfItemsInCurrentSection - 1){
                
                let indexPath = IndexPath(item: item, section: section)
                
                //Calculate attribute at given indexPath
                let (x,y) = self.calculateOriginOfItemAt(IndexPath: indexPath)
                
                // Calculate Item Width and height required for this section
                let (itemWidth,itemHeight) = self.calculateItemWidthAndHeightAt(IndexPath: indexPath)
                
                let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: x,
                                              y: y,
                                              width: itemWidth,
                                              height: itemHeight)

                // Update main attributes dictionary
                self.attributesDictionary[indexPath] = attributes
                
                // Update Section Size array
                self.updateSectionSizeDictionary(OfSection: section, ByAttributes: attributes)
            }
        }
    }
    
    ///Calculates Item Width and Height of given IndexPath. collectionView must not be nil while using this function.
    ///
    ///:param: indexPath IndexPath For which item Width and Height need to be calculated.
    ///
    ///:returns: (itemWidth: CGFloat, itemHeight: CGFloat) Width and Height of an item
    func calculateItemWidthAndHeightAt(IndexPath indexPath : IndexPath) -> (itemWidth: CGFloat, itemHeight: CGFloat){
        SPLogger.logError(Message: "SPCollectionViewLayout : Method calculateItemWidthAndHeightAt must be overridden by subclass.")
        return (0,0)
    }
    
    ///Calculates Item Origin of given indexPath. Warning self.collectionView must not be nil while using this function.
    ///
    ///:param: indexPath IndexPath For which item Origin need to be calculated.
    ///
    ///:returns: (x: CGFloat, y: CGFloat) Origin of an item
    final func calculateOriginOfItemAt(IndexPath indexPath : IndexPath) -> (x: CGFloat, y: CGFloat){
        
        if indexPath.item == 0 {
            return self.calcualateOriginOfFirstItemOfSectionAt(IndexPath: indexPath)
        }
        
        return self.calcualateOriginOfNonFirstItemOfSectionAt(IndexPath: indexPath)
    }
    
    ///Calculates First item of section. It always starts from left and below above section leaving spacing.
    ///
    ///:param: indexPath IndexPath For which item Origin need to be calculated.
    ///
    ///:returns: (x: CGFloat, y: CGFloat) Origin of an item
    func calcualateOriginOfFirstItemOfSectionAt(IndexPath indexPath : IndexPath) -> (x: CGFloat, y: CGFloat){
        SPLogger.logError(Message: "SPCollectionViewLayout : Method calcualateOriginOfFirstItemOfSectionAt must be overridden by subclass.")
        return (0,0)
    }
    
    ///Calculates Non First item of section.
    ///
    ///:param: indexPath IndexPath For which item Origin need to be calculated.
    ///
    ///:returns: (x: CGFloat, y: CGFloat) Origin of an item
    func calcualateOriginOfNonFirstItemOfSectionAt(IndexPath indexPath : IndexPath) -> (x: CGFloat, y: CGFloat){
        SPLogger.logError(Message: "SPCollectionViewLayout : Method calcualateOriginOfNonFirstItemOfSectionAt must be overridden by subclass.")
        return (0,0)
    }
    
    var oldBoundsBeforeInvalidationLayout = CGRect.zero
    // Update layout on bounds change
    final override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.width != self.collectionView!.bounds.size.width{
            oldBoundsBeforeInvalidationLayout = self.collectionView!.bounds
            return true
        }
        return false
    }
    
}

// MARK: Pass Attributes to Apple's collectionview Mechanism
extension SPCollectionViewLayout{
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attribuetsInRectArray : [UICollectionViewLayoutAttributes] = []
        for (_,attributes) in attributesDictionary{
            if rect.intersects(attributes.frame){
                attribuetsInRectArray.append(attributes)
                
                //Add Supplementary views if any
                for kind in supplementaryViewKinds{
                    guard let supplementaryAttributes = layoutAttributesForSupplementaryView(ofKind: kind, at: attributes.indexPath) else{
                        continue
                    }
                    attribuetsInRectArray.append(supplementaryAttributes)
                }
                
                //Add Decoration views if any
                for kind in decorationViewKinds{
                    guard let decorationAttributes = layoutAttributesForDecorationView(ofKind: kind, at: attributes.indexPath) else{
                        continue
                    }
                    attribuetsInRectArray.append(decorationAttributes)
                }
            }
        }
        
        return attribuetsInRectArray
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesDictionary[indexPath]
    }
}

// MARK: Memorize Content Size for each section
extension SPCollectionViewLayout{
    ///Updates Section Size array based on latest Attributes
    ///
    ///:param: section section for which section size array needs to be updated.
    ///:param: attributes Attributes which just got added/Edited due to which Section size array might need to be updated.
    final func updateSectionSizeDictionary(OfSection section : Int, ByAttributes attributes : UICollectionViewLayoutAttributes){
        if var (sectionWidth,sectionHeight) = sectionSizeDictionary[section] {
            
            if sectionWidth < (attributes.frame.origin.x + attributes.frame.size.width) {
                sectionWidth = (attributes.frame.origin.x + attributes.frame.size.width)
            }
            
            if sectionHeight < (attributes.frame.origin.y + attributes.frame.size.height) {
                sectionHeight = (attributes.frame.origin.y + attributes.frame.size.height)
            }
            sectionSizeDictionary[section] = (sectionWidth,sectionHeight)
        }else{
            sectionSizeDictionary[section] = (attributes.frame.origin.x + attributes.frame.size.width,
                attributes.frame.origin.y + attributes.frame.size.height)
        }
    }
}

// MARK: Helper methods
extension SPCollectionViewLayout{
    ///Gets line spacing required for that section if implemented by delegate otherwise will return the value present in instance variable.
    ///
    ///:param: section for which line spacing is required.
    ///
    ///:returns: CGFloat Line Spacing
    final func lineSpacing(ForSection section : Int) -> CGFloat{
        if let lineSpacing = self.delegate?.lineSpacing?(ForSection: section){
            return lineSpacing
        }
        
        return self.lineSpacing
    }
    
    ///Gets Inter Item spacing required for that section if implemented by delegate otherwise will return the value present in instance variable.
    ///
    ///:param: section for which Inter Item spacing is required.
    ///
    ///:returns: CGFloat Inter Item spacing
    final func interItemSpacing(ForSection section : Int) -> CGFloat{
        if let interItemSpacing = self.delegate?.interItemSpacing?(ForSection: section){
            return interItemSpacing
        }
        
        return self.interItemSpacing
    }
    
    ///Gets Section Inset required for that section if implemented by delegate otherwise will return the value present in instance variable.
    ///
    ///:param: section for which Section Inset is required.
    ///
    ///:returns: UIEdgeInsets Section Inset
    final func sectionInset(ForSection section : Int) -> UIEdgeInsets{
        if let sectionInset = self.delegate?.sectionInset?(ForSection: section){
            return sectionInset
        }
        
        return self.sectionInset
    }    
    
    final func updateContentOffsetForVerticalLayoutOnBoundsChange(){
        // Leave it alone if pagingEnabled
        guard !pagingEnabled else{
            return
        }
        
        // On bounds change if previous content offset was to big for current content size then
        // Reduce the new offset to contentsize height - bounds height
        
        let maxOffSetY = collectionView!.contentSize.height - collectionView!.bounds.height
        guard maxOffSetY < collectionView!.contentOffset.y &&
        maxOffSetY > 0 else{
            return
        }
        
        var newOffset = collectionView!.contentOffset
        newOffset.y = maxOffSetY
        collectionView!.setContentOffset(newOffset, animated: false)
    }
    
    
    final func updateContentOffsetForHorizontalLayoutOnBoundsChange(){
        // Leave it alone if pagingEnabled
        guard !pagingEnabled else{
            return
        }
        
        // On bounds change if previous content offset was to big for current content size then
        // Reduce the new offset to contentsize width - bounds width
        
        let maxOffSetX = collectionView!.contentSize.width - collectionView!.bounds.width
        guard maxOffSetX < collectionView!.contentOffset.x  &&
            maxOffSetX > 0 else{
            return
        }
        
        var newOffset = collectionView!.contentOffset
        newOffset.x = maxOffSetX
        collectionView!.setContentOffset(newOffset, animated: false)
    }

}


