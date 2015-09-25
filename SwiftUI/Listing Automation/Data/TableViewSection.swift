//
//  Section.swift
//  SwiftUI
//
//  Created by ibm on 26/06/15.
//  Copyright © 2015 speedui. All rights reserved.
//

import Foundation

public class TableViewSection: ArrayWrapper<ViewModelType>, TableViewSectionType{
   public var sectionHeader : String?
   public var sectionFooter : String?
      
   typealias Element = ViewModelType

   public required init(arrayLiteral elements: ViewModelType...){
      super.init(items: elements)
   }
   
}

