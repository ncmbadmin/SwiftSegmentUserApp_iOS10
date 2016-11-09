//
//  CustomCell.swift
//  SwiftSegmentUserApp
//
//  Created by NIFTY on 2016/10/31.
//  Copyright © 2016年 NIFTY Corporation. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var postBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     通常セル (内容を表示するだけ)
     @param keyStr keyラベルに表示する文字列
     @param value valueラベルに表示するオブジェクト　（文字列、配列、Dictionary）
     */
    internal func setCell(keyStr:String, value:AnyObject){
        self.keyLabel.text = keyStr;
        if !(value is NSNull) && keyStr == "mailAddressConfirm" {
            self.valueLabel.text = value as! Bool ? "true" : "false"
        } else {
            self.valueLabel.text = ConvertString.convertNSStringToAnyObject(value)
        }
    }

    /**
     value編集セル
     @param keyStr keyラベルに表示する文字列
     @param valueStr valueテキストフィールドに表示する文字列
     */
    internal func setCell(keyStr:String, editValue:AnyObject) {
        self.keyLabel.text = keyStr;
        
        self.valueField.text = ConvertString.convertNSStringToAnyObject(editValue) 
    }
    
}
