//
//  SPCellProtocol.swift
//  SpeedKit
//
//  Created by Pradip Vaghasiya on 04/08/14.
//  Copyright (c) 2014 SpeedUI. All rights reserved.
//

/// To Listing Automation to work, Cell or Item must conform to this protocol.
public protocol SPCellProtocol : class{
   weak var viewModel : ViewModelType? {get set}
   func configureCell()
}


public protocol SPTableCellProtocol : SPCellProtocol{
   weak var parentView : UITableView? {get set}
}


public protocol SPCollectionCellProtocol : SPCellProtocol{
   weak var parentView : UICollectionView? {get set}
}