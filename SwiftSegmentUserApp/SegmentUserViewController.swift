//
//  SegmentUserViewController.swift
//  SwiftSegmentUserApp
//
//  Created by FJCT on 2016/10/31.
//  Copyright 2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
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
            return TABLE_VIEW_POST_BTN_CELL_HEIGHT
        } else if self.userKeys[indexPath.row] == "acl" {
            // aclセルのみ２行で表示する
            return MULTI_LINE_CELL_HEIGHT
        }
        
        return TABLE_VIEW_CELL_HEIGHT
    }
    
    /**
     TableViewのCellを返します。
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:CustomCell!
        
        if indexPath.row < self.userKeys.count {
            // 最後のセル以外
            let keyStr = self.userKeys[indexPath.row] as String
            let value = self.user[keyStr]! as AnyObject
            
            if !self.initialUserKeys.contains(keyStr) {
                // 既存フィールド以外とchannelsはvalueを編集できるようにする
                cell = tableView.dequeueReusableCell(withIdentifier: EDIT_CELL_IDENTIFIER) as? CustomCell
                if cell == nil {
                    cell = CustomCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: EDIT_CELL_IDENTIFIER)
                }
                cell.setCell(keyStr: keyStr, editValue: value)
                cell.valueField.delegate = self
                cell.valueField.tag = indexPath.row
            } else {
                // 編集なしのセル (表示のみ)
                if keyStr == "acl" {
                    // 表示文字数が多いセルはセルの高さを変更して全体を表示させる
                    cell = tableView.dequeueReusableCell(withIdentifier: MULTI_LINE_CELL_IDENTIFIER) as? CustomCell
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: MULTI_LINE_CELL_IDENTIFIER)
                    }
                } else {
                    // 通常のセル
                    cell = tableView.dequeueReusableCell(withIdentifier: NOMAL_CELL_IDENTIFIER) as? CustomCell
                    if cell == nil {
                        cell = CustomCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: NOMAL_CELL_IDENTIFIER)
                    }
                }
                cell.setCell(keyStr: keyStr, value: value)
                
            }
        } else {
            // 最後のセルは追加用セルと登録ボタンを表示
            cell = tableView.dequeueReusableCell(withIdentifier: ADD_CELL_IDENTIFIER) as? CustomCell
            if cell == nil {
                cell = CustomCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: ADD_CELL_IDENTIFIER)
            }
            
            cell.keyField.delegate = self
            cell.keyField.tag = indexPath.row
            cell.keyField.text = self.addFieldManager.keyStr
            cell.valueField.delegate = self
            cell.valueField.tag = indexPath.row
            cell.valueField.text = self.addFieldManager.valueStr
            cell.postBtn.addTarget(self, action: #selector(postUser(sender:)), for: UIControl.Event.touchUpInside)
        }
        return cell;
    }
    
    // MARK: requestUser

    /**
     最新のuser情報を取得します。
     */
    func getUser() {
        self.user = NCMBUser.currentUser
        self.userKeys = Array(self.user._fields.keys)
        // 追加fieldの値を初期化する
        self.addFieldManager.keyStr = ""
        self.addFieldManager.valueStr = ""
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /**
     送信ボタンをタップした時に呼ばれます
     */
    @objc func postUser(sender:UIButton) {
        
        // textFieldの編集を終了する
        self.view.endEditing(true)
        
        // 追加フィールドにvalueだけセットされてkeyには何もセットされていない場合
        if self.addFieldManager.valueStr != "" && self.addFieldManager.keyStr == "" {
            self.statusLabel.text = "key,valueをセットで入力してください"
            return
        }
        
        // 追加用セルの値をuserにセットする
        if self.addFieldManager.keyStr != "" {
            // keyに値が設定されていた場合
            if self.addFieldManager.valueStr.range(of: ",") != nil {
                // value文字列に[,]がある場合は配列に変換してuserにセットする
                self.user[self.addFieldManager.keyStr] = self.addFieldManager.valueStr.components(separatedBy: ",")
            } else {
                self.user[self.addFieldManager.keyStr] = self.addFieldManager.valueStr
            }
        }
        
        // user情報を更新
        self.user.saveInBackground(callback: { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.statusLabel.text = "保存に成功しました"
                }
                // tableViewの内容を更新
                self.getUser()
            case let .failure(error):
                DispatchQueue.main.async {
                    self.statusLabel.text = "保存に失敗しました:\(error)"
                }
                print("Error: \(error)")
                // 保存に失敗した場合は、userから削除する
            }
        })
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
            let userValueStr = ConvertString.convertNSStringToAnyObject(self.user[userKeys[textField.tag]]! as AnyObject)
            if userValueStr != textField.text {
                // valueの値に変更がある場合はuserを更新する
                if textField.text?.range(of: ",") != nil {
                    // value文字列に[,]がある場合は配列に変換してuserにセットする
                    self.user[self.userKeys[textField.tag]] = textField.text?.components(separatedBy: ",")
                } else {
                    // それ以外は文字列としてuserにセットする
                    self.user[self.userKeys[textField.tag]] = textField.text
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
        
        var keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        keyboardRect = self.view.superview!.convert(keyboardRect, to: nil)
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        
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
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        
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
        _ = NCMBUser.logOut()
        self.dismiss(animated: true, completion: nil)
        print("ログアウトしました")
    }
    
}


