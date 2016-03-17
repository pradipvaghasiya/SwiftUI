//
//  SPListingDataSourceType.swift
//  SwiftUI
//
//  Created by Pradip V on 29/06/15.
//  Copyright © 2015 SpeedUI. All rights reserved.
//

import Foundation
public protocol SPListingDataSourceType{
   
}

public protocol SPTableListingDataSourceType : SPListingDataSourceType{
   unowned var controller : SPTableListingControllerType {get}
}

public protocol SPCollectionListingDataSourceType : SPListingDataSourceType{
   unowned var controller : SPCollectionListingControllerType {get}
}