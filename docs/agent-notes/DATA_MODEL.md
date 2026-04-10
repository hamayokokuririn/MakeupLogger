# MakeupLogger Data Model

このアプリのデータモデルは、中心に `MakeupLog` と `ColorPallet` があり、それぞれが画像パスと注釈の集合を持つ構造です。永続化は Realm で、スキーマバージョンは `6` です。

## 主要モデル

### `MakeupLog`

メイク記録本体です。

- `id: MakeupLogID?`
- `title: String`
- `body: String?`
- `imagePath: String`
- `createAt: Date`
- `partsList: List<FacePart>`

役割:

- 顔全体のメイク記録を表すルートエンティティ
- 顔写真 1 枚と、複数の顔パーツを保持する
- 作成時に `eye`、`lip`、`cheek` のデフォルト部位が生成される

定義:

- `MakeupLogger/Domain/MakeupLog.swift`

### `FacePart`

顔の部位を表します。

- `id: FacePartID?`
- `type: String`
- `imagePath: String`
- `createAt: Date`
- `annotations: List<FaceAnnotationObject>`

役割:

- `MakeupLog` に属する部位単位の情報
- 例: `eye`, `lip`, `cheek`
- 各部位ごとに画像と注釈一覧を持つ

定義:

- `MakeupLogger/Domain/FacePart.swift`

### `ColorPallet`

カラーパレット本体です。

- `id: ColorPalletID?`
- `title: String`
- `imagePath: String?`
- `createAt: Date`
- `annotationList: List<ColorPalletAnnotationObject>`

役割:

- 色見本やコスメの配置画像を保持する
- 注釈ごとに色名などを管理する
- `FaceAnnotationObject` から参照される

定義:

- `MakeupLogger/Domain/ColorPallet.swift`

## 注釈モデル

### `FaceAnnotationObject`

メイク部位上の注釈です。

- `id: FaceAnnotationID?`
- `text: String`
- `pointRatioOnImage: PointRatio?`
- `title: String`
- `comment: String?`
- `selectedColorPalletID: ColorPalletID?`
- `selectedColorPalletAnnotationID: ColorPalletAnnotationID?`
- `createAt: Date`

役割:

- 顔パーツ画像上のマーカー情報
- 注釈タイトルとコメントを保持する
- 「どのカラーパレットのどの色を使ったか」を参照で持つ

補足:

- `selectedColorPalletID` が変わると `selectedColorPalletAnnotationID` は `nil` にリセットされる

定義:

- `MakeupLogger/Domain/Annotation/FaceAnnotationObject.swift`

### `ColorPalletAnnotationObject`

カラーパレット上の注釈です。

- `id: ColorPalletAnnotationID?`
- `text: String`
- `title: String`
- `pointRatioOnImage: PointRatio?`

役割:

- パレット画像上のマーカー情報
- 各注釈に色名やラベルを持たせる

定義:

- `MakeupLogger/Domain/Annotation/ColorPalletAnnotationObject.swift`

### `PointRatio`

注釈の位置を画像サイズに対する比率で保持する補助モデルです。

- `x: Float`
- `y: Float`

役割:

- 画像の実サイズに依存せず注釈位置を保存する
- 再描画時に画像表示領域に合わせて座標を再計算できる

定義:

- `MakeupLogger/Domain/Annotation/FaceAnnotationObject.swift`

## ID モデル

各エンティティは `String` を内包する専用 ID クラスを持っています。

- `MakeupLogID`
- `FacePartID`
- `FaceAnnotationID`
- `ColorPalletID`
- `ColorPalletAnnotationID`

特徴:

- いずれも Realm `Object` として定義されている
- 内部では `UUID().uuidString` を使用している
- 一部の ID は画像保存時のファイル名やフォルダ名の生成にも使われる

## モデル間の関係

- `MakeupLog` 1件に対して `FacePart` が複数ぶら下がる
- `FacePart` 1件に対して `FaceAnnotationObject` が複数ぶら下がる
- `ColorPallet` 1件に対して `ColorPalletAnnotationObject` が複数ぶら下がる
- `FaceAnnotationObject` は `selectedColorPalletID` と `selectedColorPalletAnnotationID` で `ColorPallet` 側を参照する

要するに、顔のどの位置にどのメイクをしたかを `FaceAnnotationObject` で表し、その注釈がどのカラーパレットのどの色に対応するかを紐づける設計です。

## 構造図

```text
MakeupLog
  ├─ id: MakeupLogID
  ├─ title
  ├─ body
  ├─ imagePath
  └─ partsList: [FacePart]
       ├─ id: FacePartID
       ├─ type
       ├─ imagePath
       └─ annotations: [FaceAnnotationObject]
            ├─ id: FaceAnnotationID
            ├─ text
            ├─ title
            ├─ comment
            ├─ pointRatioOnImage
            ├─ selectedColorPalletID
            └─ selectedColorPalletAnnotationID

ColorPallet
  ├─ id: ColorPalletID
  ├─ title
  ├─ imagePath
  └─ annotationList: [ColorPalletAnnotationObject]
       ├─ id: ColorPalletAnnotationID
       ├─ text
       ├─ title
       └─ pointRatioOnImage
```

## 永続化の補足

- Realm には主にメタデータと参照関係が保存される
- 画像データ自体は Realm に格納せず、Documents 配下に保存して `imagePath` で参照する
- リポジトリ層が Realm 保存と画像ファイル保存の両方を担う

関連ファイル:

- `MakeupLogger/DataStore/MakeupLogRepository.swift`
- `MakeupLogger/DataStore/ColorPalletRepository.swift`
- `MakeupLogger/Utility/FileIOUtil.swift`
- `MakeupLogger/Config/RealmConfig.swift`
