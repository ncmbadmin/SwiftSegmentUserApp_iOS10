//
//  SegmentUserViewController.swift
//  SwiftSegmentUserApp
//
//  Created by NIFTY on 2016/10/31.
//  Copyright © 2016年 NIFTY Corporation. All rights reserved.
//

import UIKit
import NCMB

class SegmentUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // user情報を表示するリスト
    @IBOutlet weak var tableView: UITableView!
    // 通信結果を表示するラベル
    @IBOutlet weak var statusLabel: UILabel!
    // user情報
    var user:NCMBUser! = nil
    // currentUserに登録されているkeyの配列
    var userKeys:Array<String> = []
    // user情報で初期で登録されているキー
    let initialUserKeys = ["objectId","userName","password","mailAddress","authData","sessionInfo","mailAddressConfirm","temporaryPassword","createDate","updateDate","acl","sessionToken"]
    // 追加セルのマネージャー
    var addFieldManager = (keyStr:"",valueStr:"")
    // textFieldの位置情報
    var textFieldPosition:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = "ログインに成功しました"
        
        // tableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // user情報を取得
        self.getUser()
    }
    
    // MARK: TableViewDataSource
    
    /**
     TableViewのheaderViewを返します。
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "sectionHeader")
    }
    
    /**
     TableViewのCellの数を設定します。
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userKeys.count + 1
    }
    
    /**
     TableViewのCellの高さを設定します。
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == self.userKeys.count {
            return CGFloat(TABLE_VIEW_POST_BTN_CELL_HEIGHT)
        } else if self.userKeys[indexPath.row] == "acl" {
            // aclセルのみ２行で表示する
            return CGFloat(MULTI_LINE_CELL_HEIGHT)
        }
        
        return CGFloat(TABLE_VIEW_CELL_HEIGHT)
    }
    
    /**
     TableViewのCellを返します。
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:CustomCell!
        
        if indexPath.row < self.userKeys.count {
            // 最後のセル以外
            let keyStr:String = self.userKeys[indexPath.row]
            let value = self.user.object(forKey:keyStr)
            
            if !self.initialUserKeys.contains(keyStr) {
                // 既存フィールド以外とchannelsはvalueを編集できるようにする
                cell = tableView.dequeueReusableCell(withIdentifier: EDIT_CELL_IDENTIFIER) as! CustomCell!
                if cell == nil {
                    cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: EDIT_CELL_IDENTIFIER)
                }
                cell.setCell(keyStr: keyStr, editValue: value as AnyObject)
                cell.valueField.delegate = self
                cell.valueField.tag = indexPath.row
            } else {
                // 編集なしのセル (表示のみ)
                if keyStr == "acl" {
                    // 表示文字数が多いセルはセルの高さを変更して全体を表示させる
                    cell = tableView.dequeueReusableCell(withIdentifier: MULTI_LINE_CELL_IDENTIFIER) as! CustomCell!
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: MULTI_LINE_CELL_IDENTIFIER)
                    }
                } else {
                    // 通常のセル
                    cell = tableView.dequeueReusableCell(withIdentifier: MULTI_LINE_CELL_IDENTIFIER) as! CustomCell!
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: MULTI_LINE_CELL_IDENTIFIER)
                    }
                }
                cell.setCell(keyStr: keyStr, value: value as AnyObject)
                
            }
        } else {
            // 最後のセルは追加用セルと登録ボタンを表示
            cell = tableView.dequeueReusableCell(withIdentifier: ADD_CELL_IDENTIFIER) as! CustomCell!
            if cell == nil {
                cell = CustomCell(style: UITableViewCellStyle.default, reuseIdentifier: ADD_CELL_IDENTIFIER)
            }
            
            cell.keyField.delegate = self
            cell.keyField.tag = indexPath.row
            cell.keyField.text = self.addFieldManager.keyStr
            cell.valueField.delegate = self
            cell.valueField.tag = indexPath.row
            cell.valueField.text = self.addFieldManager.valueStr
            cell.postBtn.addTarget(self, action: #selector(postUser(sender:)), for: UIControlEvents.touchUpInside)
        }
        return cell;
    }
    
    // MARK: requestUser

    /**
     最新のuser情報を取得します。
     */
    func getUser() {
        let user = NCMBUser.current()
        
        user?.fetchInBackground({ (error) in
            if let unwrapError = error as? NSError {
                // 新規登録失敗時の処理
                self.statusLabel.text = "取得に失敗しました:\(unwrapError.code)"
            } else {
                // ユーザー情報の取得が成功した場合の処理
                print("取得に成功")
                self.user = user
                self.userKeys = user?.allKeys() as! Array<String>!
                // 追加fieldの値を初期化する
                self.addFieldManager.keyStr = ""
                self.addFieldManager.valueStr = ""
                self.tableView.reloadData()
            }
        })
    }
    
    /**
     送信ボタンをタップした時に呼ばれます
     */
    func postUser(sender:UIButton) {
        // 追加用セルの値をuserにセットする
        if self.addFieldManager.keyStr != "" {
            // keyに値が設定されていた場合
            if self.addFieldManager.valueStr.range(of: ",") != nil {
                // value文字列に[,]がある場合は配列に変換してuserにセットする
                self.user.setObject(self.addFieldManager.valueStr.components(separatedBy: ","), forKey: self.addFieldManager.keyStr)
            } else {
                self.user.setObject(self.addFieldManager.valueStr, forKey: self.addFieldManager.keyStr)
            }
        }
        
        // user情報を更新
        self.user.saveInBackground { (error) in
            if let unwrapError = error as? NSError {
                self.statusLabel.text = "保存に失敗しました:\(unwrapError.code)"
            } else {
                self.statusLabel.text = "保存に成功しました"
                // tableViewの内容を更新
                self.getUser()
            }
        }
    }
    
    // MARK: TextFieldDelegate
    
    /**
     キーボードの「Return」押下時の処理
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    /**
     textFieldの編集を開始したら呼ばれます
     textFieldの位置情報をセットします
     */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let indexpath = NSIndexPath.init(row: textField.tag, section: 0)
        
        let rectOfCellInTableView = self.tableView.rectForRow(at: indexpath as IndexPath)
        let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
        // textFieldの位置情報をセット
        self.textFieldPosition = rectOfCellInSuperview.origin.y
        
        return true
    }
    
    /**
     textFieldの編集が終了したら呼ばれます
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        // tableViewのdatasorceを編集する
        if textField.tag < self.userKeys.count {
            // 最後のセル以外はuserを更新する
            let userValueStr = ConvertString.convertNSStringToAnyObject(self.user.object(forKey: self.userKeys[textField.tag]) as AnyObject)
            if userValueStr != textField.text {
                // valueの値に変更がある場合はuserを更新する
                if textField.text?.range(of: ",") != nil {
                    // value文字列に[,]がある場合は配列に変換してuserにセットする
                    self.user.setValue(textField.text?.components(separatedBy: ","), forKey: self.userKeys[textField.tag])
                } else {
                    // それ以外は文字列としてuserにセットする
                    self.user.setValue(textField.text, forKey: self.userKeys[textField.tag])
                }
            }
            
        } else {
            // 追加セルはmanagerクラスを更新する（user更新時に保存する）
            let cell = self.tableView.cellForRow(at: NSIndexPath.init(row: textField.tag, section: 0) as IndexPath) as! CustomCell?
            if textField == cell!.keyField {
                // keyFieldの場合
                if self.addFieldManager.keyStr != textField.text {
                    // keyの値に変更がある場合はマネージャーを更新する
                    self.addFieldManager.keyStr = textField.text!
                }
            } else {
                // valueFieldの場合
                if (self.addFieldManager.valueStr != textField.text) {
                    // valueの値に変更がある場合はマネージャーを更新する
                    self.addFieldManager.valueStr = textField.text!
                }
            }
        }
    }
    
    // MARK: keyboardWillShow
    
    /**
     キーボードが表示されたら呼ばれる
     */
    func keyboardWillShow(_ notification: NSNotification) {
        
        var keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        keyboardRect = self.view.superview!.convert(keyboardRect, to: nil)
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
        
        let keyboardPosition = self.view.frame.size.height - keyboardRect.size.height as CGFloat
        
        // autoLayoutを解除
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        
        // 編集するtextFieldの位置がキーボードより下にある場合は、位置を移動する
        if self.textFieldPosition + CGFloat(TABLE_VIEW_CELL_HEIGHT) > keyboardPosition {
            UIView.animate(withDuration: duration as! Double, animations: { () -> Void in
                // アニメーションでtextFieldを動かす
                var rect = self.tableView.frame
                rect.origin.y = keyboardRect.origin.y - self.textFieldPosition
                self.tableView.frame = rect
            })
        }
    }
    
    /**
     キーボードが隠れると呼ばれる
     */
    func keyboardWillHide(_ notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
        
        // autoLayoutに戻す
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // アニメーションでtextFieldを動かす
        UIView.animate(withDuration: duration as! Double, animations: { () -> Void in
            // アニメーションでtextFieldを動かす
            var rect = self.tableView.frame
            rect.origin.y = self.view.frame.size.height - self.tableView.frame.size.height
            self.tableView.frame = rect
        })
    }
    
    // 背景をタップするとキーボードを隠す
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Logoutボタン押下時の処理
    @IBAction func logoutBtn(_ sender: UIButton) {
        NCMBUser.logOut()
        self.dismiss(animated: true, completion: nil)
        print("ログアウトしました")
    }
    
}


