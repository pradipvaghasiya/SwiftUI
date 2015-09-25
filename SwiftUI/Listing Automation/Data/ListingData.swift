//
//  TableViewData.swift
//  SwiftUI
//
//  Created by ibm on 26/06/15.
//  Copyright © 2015 speedui. All rights reserved.
//

import Foundation


public class ListingData<T : SectionType> : ArrayWrapper<T>{

   public required init(arrayLiteral elements: T...){
      super.init(items: elements)
   }

}





