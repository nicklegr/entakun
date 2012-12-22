# entakun
Webブラウザで使える、付箋に書くように手軽なタスク管理ツールです。  
1〜6人程度の少人数のチームに向いています。

## デモ
[entakun.co](http://entakun.co) にて、Webサービスとして利用できます。  
試しにプロジェクトを作って、使ってみてください。

## 特徴
- 1クリックでプロジェクトを作成し、すぐに使えます。
  - アカウント作成やログインは不要です。
- キーボードだけでタスクを追加できます。
  - たとえば会議中でも、その場でサクサク新しいタスクを追加できます。
- 担当者の割り当て・タスクの完了は、ドラッグ&ドロップで直感的に行えます。
- プロジェクトのURLを伝えるだけで、共同作業ができます。
- 他のプロジェクトのメンバーを「フォロー」して、作業内容を見ることができます。

## インストール
entakunの動作には、下記のものが必要です。

- Ruby (>= 1.9.3)
- Bundler (>= 1.2.0)
- MongoDB
- Java (production環境のみ)

MongoDBのユーザー認証は使用していません。  
またデータベースも自動的に作成されるので、デフォルト状態で起動させるだけでOKです。

Javaのインストールが難しい場合は、config.ruの下記の記述を削除することで、Javaがなくても動作します。

```ruby:config.ru
if ENV['RACK_ENV'] == 'production'
  environment.js_compressor  = YUI::JavaScriptCompressor.new(munge: true)
  environment.css_compressor = YUI::CssCompressor.new
end
```

## テスト起動
```bash
$ git clone git://github.com/nicklegr/entakun.git

$ cd entakun
$ bundle install
$ bundle exec rackup
```

これで、entakunが起動します。
[http://localhost:9292/](http://localhost:9292/) にアクセスしてみてください。

## 本番運用
nginx + thin, Apache + Phusion Passengerでの動作を確認しています。  
一般的なsinatra(rack)アプリと同様にセットアップしてください。

## スタッフ
- 企画・デザイン
  - 袴忠 (Hakama Tadashi)
- プログラム・マークアップ
  - にっくる ([@nicklegr](https://twitter.com/nicklegr))

## ライセンス
entakun本体は、MITライセンスを適用します。詳細はLICENSE.txtをご覧ください。

同梱されている各種ライブラリについては、それぞれのライセンスに従います。  
MIT,GPLのデュアルライセンスの場合は、MITライセンスを選択します。
