//
//  ConvertString.swift
//  SwiftSegmentUserApp
//
//  Created by oono on 2016/10/31.
//  Copyright © 2016年 NIFTY Corporation. All rights reserved.
//

import UIKit

class ConvertString: NSObject {

    /**
     installationのvalueの値をNSStringクラスに変換する
     @param anyObject NSArray or NSDictionary or NSString オブジェクト
     @return 文字列
     */
    internal static func convertNSStringToAnyObject(_ anyObject:Any) -> String {
        
        if let arrayObject = anyObject as? [String] {
            // NSArrayをNSStringに変換する
            return arrayObject.joined(separator: ",")
        } else if let dicObject = anyObject as? Dictionary<String, AnyObject> {
            // NSDictionaryをNSStringに変換する
            do {
                let data = try JSONSerialization.data(withJSONObject:dicObject, options: JSONSerialization.WritingOptions.init(rawValue: 2))
                let jsonStr:NSString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)!
                return String(jsonStr)
            } catch {
                // Error Handling
                print("JSONSerialization Error")
                return ""
            }
        } else {
            return String(describing: anyObject)
        }
    }
}
