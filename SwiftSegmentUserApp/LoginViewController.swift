//
//  LoginViewController.swift
//  SwiftSegmentUserApp
//
//  Created by NIFTY on 2016/10/31.
//  Copyright © 2016年 NIFTY Corporation. All rights reserved.
//

import UIKit
import NCMB

class LoginViewController: UIViewController {
    // User Name
    @IBOutlet weak var userNameTextField: UITextField!
    // Password
    @IBOutlet weak var passwordTextField: UITextField!
    // errorLabel
    @IBOutlet weak var errorLabel: UILabel!
    
    // 画面表示時に実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        // Passwordをセキュリティ入力に設定する
        self.passwordTextField.isSecureTextEntry = true
        
    }
    
    // Loginボタン押下時の処理
    @IBAction func loginBtn(_ sender: UIButton) {
        // キーボードを閉じる
        closeKeyboad()
        
        // 入力確認
        if self.userNameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty {
            self.errorLabel.text = "未入力の項目があります"
            // TextFieldを空に
            self.cleanTextField()
            
            return
            
        }
        
        // ユーザー名とパスワードでログイン
        NCMBUser.logInWithUsername(inBackground: self.userNameTextField.text, password: self.passwordTextField.text, block:{(user, error) in
            // TextFieldを空に
            self.cleanTextField()
            if error == nil {
                // 新規登録成功時の処理
                self.performSegue(withIdentifier: "login", sender: self)
                print("ログインに成功しました:\(user?.objectId)")
            } else {
                // 新規登録失敗時の処理
                self.errorLabel.text = "ログインに失敗しました:\((error as! NSError).code)"
                print("ログインに失敗しました:\((error as! NSError).code)")
            }
        })
        
    }
    
    // SignUp画面へ遷移
    @IBAction func toSignUp(_ sender: UIButton) {
        // TextFieldを空にする
        cleanTextField()
        // errorLabelを空に
        cleanErrorLabel()
        // キーボードを閉じる
        closeKeyboad()
        
        self.performSegue(withIdentifier: "loginToSignUp", sender: self)
        
    }
    
    // 背景タップするとキーボードを隠す
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    // TextFieldを空にする
    func cleanTextField(){
        userNameTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    // errorLabelを空にする
    func cleanErrorLabel(){
        errorLabel.text = ""
        
    }
    
    // キーボードを閉じる
    func closeKeyboad(){
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }

}
