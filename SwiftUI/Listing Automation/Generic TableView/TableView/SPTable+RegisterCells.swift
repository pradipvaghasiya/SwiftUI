//
//  SPTable+RegisterCells.swift
//  SpeedKitDemo
//
//  Created by ibm on 19/06/15.
//  Copyright © 2015 Happyfall. All rights reserved.
//

import UIKit

//MARK: Register Nib Or Subclass
extension SPTableView{
   ///Registers all nib file or Subclass which may be in SPListingData for reuse purpose.
   final func registerReusableCellsIfRequired(){
      for sectionDetail in spListingData.spListingSectionArray{
         for cellData in sectionDetail.spCellGroupArray{
            self.registerCellsFor(CellGroup: cellData)
         }
      }
   }
   
   ///Registers given cell using CellData.
   ///
   ///:param: cellData Registers class based on its type and cell Id contained in this param.
   final func registerCellsFor(CellGroup cellGroup : SPListingCellGroup){
      if let cellId = cellGroup.cellId{
         switch cellGroup.cellType{
         case .SubclassCell:
            if let cellClass = NSClassFromString(cellId){
               if cellClass.isSubclassOfClass(UITableViewCell){
                  self.registerClass(NSClassFromString(cellId),forCellReuseIdentifier: cellId)
               }
            }else{
               SPLogger.logError(Message: "\(cellId) must be subclass of UITableViewCell to use it with SPTableView.")
            }
         case .NibCell:
            self.registerNib(UINib(nibName: cellId, bundle: nil),
               forCellReuseIdentifier: cellId)
            
         case .PrototypeCell:
            true
         }
         
      }
   }
}