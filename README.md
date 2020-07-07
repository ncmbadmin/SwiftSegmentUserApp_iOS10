# 【iOS10 Swift】ユーザー情報を更新してみよう！
*2016/10/26作成*

![画像01](/readme-img/001.png)

## 概要
* [ニフクラmobile backend](https://mbaas.nifcloud.com/)の『会員管理機能』を利用してObjective-Cアプリにログイン機能を実装し、ユーザー情報を更新するサンプルプロジェクトです
* 簡単な操作ですぐに [ニフクラmobile backend](https://mbaas.nifcloud.com/)の機能を体験いただけます★☆
* このサンプルはiOS10に対応しています
 * iOS8以上でご利用いただけます

## ニフクラmobile backendって何？？
スマートフォンアプリのバックエンド機能（プッシュ通知・データストア・会員管理・ファイルストア・SNS連携・位置情報検索・スクリプト）が**開発不要**、しかも基本**無料**(注1)で使えるクラウドサービス！

注1：詳しくは[こちら](https://mbaas.nifcloud.com/price.htm)をご覧ください

![画像02](/readme-img/002.png)

## 動作環境
* Mac OS 10.15.5(Catalina)
* Simulator iOS 13.5.1
* Swift SDK v1.1.0

※上記内容で動作確認をしています

## 作業の手順
### 1. [ニフクラmobile backend](https://mbaas.nifcloud.com/)の会員登録とログイン

* 上記リンクから会員登録（無料）をします。登録ができたらログインをすると下図のように「アプリの新規作成」画面が出るのでアプリを作成します

![画像03](/readme-img/003.png)

* アプリ作成されると下図のような画面になります
* この２種類のAPIキー（アプリケーションキーとクライアントキー）はXcodeで作成するiOSアプリに[ニフクラmobile backend](https://mbaas.nifcloud.com/)を紐付けるために使用します

![画像04](/readme-img/004.png)

* 動作確認後に会員情報が保存される場所も確認しておきましょう

![画像05](/readme-img/005.png)

### 2. [GitHub](https://github.com/NIFCLOUD-mbaas/SwiftSegmentUserApp_iOS10)からサンプルプロジェクトのダウンロード

* 下記リンクをクリックしてプロジェクトをダウンロードをMacにダウンロードします

 * __[SwiftSegmentUserApp](https://github.com/NIFCLOUD-mbaas/SwiftSegmentUserApp_iOS10/archive/master.zip)__

### 3. Xcodeでアプリを起動

* ダウンロードしたフォルダを開き、「__SwiftSegmentUserApp.xcworkspace__」をダブルクリックしてXcode開きます(白い方です)

![画像09](/readme-img/009.png)
![画像06](/readme-img/006.png)

* 「SwiftSegmentUserApp.xcodeproj」（青い方）ではないので注意してください！

![画像08](/readme-img/008.png)

### 4. APIキーの設定

* `AppDelegate.swift`を編集します
* 先程[ニフクラmobile backend](https://mbaas.nifcloud.com/)のダッシュボード上で確認したAPIキーを貼り付けます

![画像07](/readme-img/007.png)

* それぞれ`YOUR_NCMB_APPLICATION_KEY`と`YOUR_NCMB_CLIENT_KEY`の部分を書き換えます
 * このとき、ダブルクォーテーション（`"`）を消さないように注意してください！
* 書き換え終わったら`command + s`キーで保存をします

### 5. 動作確認
* Xcode画面の左上、適当なSimulatorを選択します
 * iPhone7の場合は以下のようになります
* 実行ボタン（さんかくの再生マーク）をクリックします

* アプリが起動したら、Login画面が表示されます
* 初回は __`SignUp`__ ボタンをクリックして、会員登録を行います

![画像13](/readme-img/013.png)

* `User Name`と`Password`を２つ入力して![画像12](/readme-img/012.png)ボタンをタップします
* 会員登録が成功するとログインされ、下記ユーザー情報の一覧が表示されます
* SignUpに成功するとmBaaS上に会員情報が作成されます！

![画像14](/readme-img/014.png)

* ログインに失敗した場合は画面にエラーコードが表示されます
* エラーが発生した場合は、[こちら](https://mbaas.nifcloud.com/doc/current/rest/common/error.html)よりエラー内容を確認いただけます

#### 新しいフィールドの追加
* 新しいフィールドの追加をしてみましょう。"favorite"というフィールドを作り、中身には"music"と入れてみました。こうすることで、ユーザー情報に新しい属性を付与することができるようになります！
* 編集が完了したら更新ボタンをタップして下さい

![画像15](/readme-img/015.png)

* 更新後、tableViewが自動でリロードされ、追加・更新が行われていることがわかります。追加したフィールドは後から編集することが可能です

![画像16](/readme-img/016.png)

* ダッシュボードから、更新ができていることを確認してみましょう！

![画像17](/readme-img/017.png)

## 解説
* 下記３点について解説します
 * 会員登録
 * ログイン
 * 会員情報の取得

### 会員登録
`SignUpViewController.swift`

```swift
let user = NCMBUser()
        //ユーザー名を設定
        user.userName = self.userNameTextField.text
        //パスワードを設定
        user.password = self.passwordTextField.text
        
        //会員の登録を行う
        user.signUpInBackground(callback: { result in
            // TextFieldを空に
            DispatchQueue.main.async {
                self.cleanTextField()
            }
            
            switch result {
                case .success:
                    // 新規登録成功時の処理
                    
                case let .failure(error):
                    // 新規登録失敗時の処理
                    
                }
        })
    }
```

### ログイン

```swift
// ログイン
NCMBUser.logInInBackground(userName: self.userNameTextField.text!, password: self.passwordTextField.text!, callback: { result in
            // TextFieldを空に
            DispatchQueue.main.async {
                self.cleanTextField()
            }
            
            switch result {
            case .success:
                // ログインに成功した場合の処理
            case let .failure(error):
                // 新規登録失敗時の処理
            }
        })         
```

### 会員情報の取得
`SegmentUserViewController.swift`

```swift
//会員情報をカレントユーザーから取得
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
```

## 参考
* 同じ内容の【Objective-C】版もご用意しています
 * [ObjcSegmentUserApp_iOS10](https://github.com/NIFCLOUD-mbaas/ObjcSegmentUserApp_iOS10)
