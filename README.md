# Dice MOD for DisplayDeck / DisplayDeck 用 ダイス MOD

Repository: https://github.com/willailora/DiceDisplayDeckMOD

---

## 日本語

### これは何
DisplayDeck の **MOD（別に配る追加の機能）** です。タイルを押すと、設定したダイスを振ります。合計を大きく、出目を小さく出します。

- 書き方の例: `1D100`、`2D20`、`3D6+2`、`10D6-3`（大文字・小文字、全角の文字でも読めます）
- ダイスの数は 1〜100 個、面の数は 2〜100000、足す・引く数は 0〜999999 です。数を省くと 1 個（`D20` は `1D20`）です。
- 設定を空のままにすると `1D100` を振ります。
- 出目を1つずつ出すのは、ダイスが 2〜6 個のときと、1 個で足す・引く数があるときです（1D100 のように 1 個だけのときと、7 個からは、合計と書き方だけ）。
- 乱数は Windows の暗号用の乱数で、出目にかたよりが出ないように振っています。
- 通信はしません。ファイルも書きません。

### 入れ方
1. このリポジトリをダウンロードします（Code → Download ZIP）。
2. 展開してできたフォルダーを、DisplayDeck の MOD のフォルダーに入れます。
   - 場所は、DisplayDeck の設定画面でタイルの種類を「MOD（追加の機能）」にして、「MOD のフォルダーを開く」を押すと開きます。
     ふつうは `%APPDATA%\DisplayDeck\mods\`、ポータブル版は `<DisplayDeck のフォルダー>\mods\` です。
   - フォルダーの名前は何でもかまいません。ただし、`mod.json` と `dice.ps1` がフォルダーの直下にあるようにしてください。
3. DisplayDeck の設定画面で、次の順に操作します。
   1. タイルを選び、種類を「MOD（追加の機能）」にします。
   2. 設定画面を開いたままフォルダーを入れたときは、「一覧を更新」を押します。
   3. MOD を「ダイス」にして、「この MOD を確かめて使う」を押します。
   4. 「ダイス」の欄に `2D20` などを入れます。
4. タッチ画面でそのタイルを押すと、ダイスを振ります。
   - 振るダイスごとにタイルを分けられます。
   - タイルの「表示名」に「1D100」などと付けると、見分けやすくなります。

### アイコン（1〜6 の目）
- ダイスのタイルをいくつも並べる人のために、目の違うアイコンを 6 種類入れてあります（`dice-1.png`〜`dice-6.png`）。
- 既定は 5 の目です。変えるときは、タイルの「アイコン」で「画像を選ぶ…」を押し、MOD のフォルダーから選びます。

### 注意
- この MOD は、**予告なく使えなくなることがあります**（DisplayDeck の変更などによります）。
- この MOD を使ったことで起きたことについて、作者は**一切の責任を負いません**。
- 確認の仕組み: DisplayDeck は、MOD のフォルダーの中身を確かめてから動かします。中のファイルを書き換える・足す・消すと、「確かめて使う」を押したことのある中身に戻すか、もう一度押すまで動きません。

### MOD の作り方（このリポジトリは見本も兼ねています）
DisplayDeck の MOD は、`mods` フォルダーに入れたフォルダー1つです。フォルダーの直下に、`mod.json` と実行するファイル（`.ps1` か `.exe`）を置きます。

**mod.json**

| 項目 | 内容 |
|---|---|
| `id` | 英小文字・数字・`-`・`_`（40 文字まで）。ほかの MOD と重ならない名前 |
| `kind` | `tile`（押すと動くタイル）か `weather`（時計のカードの天気の取り先） |
| `name` / `name_ja` | 表示名（日本語の画面では `name_ja`） |
| `version` | 版 |
| `command` | 実行するファイル名（`.ps1` か `.exe`）。フォルダーの外は指せません |
| `icon` | タイルのアイコン（`.png` か `.jpg`、任意。384×384 くらい） |
| `hosts` | 通信先の一覧（確認の画面に出ます。通信しないなら `[]`） |
| `settings` | 設定の欄（3つまで）: `key`・`label`・`label_ja`・`default` |
| 天気だけ | `intervalMinutes`（15〜360）・`credit`・`credit_ja`・`creditUrl`（https）・`creditShort`（天気の隣に出す短い出典） |

**DisplayDeck から渡すもの（環境変数）**
- `DISPLAYDECK_SETTING_<KEY を大文字>`: 設定の値（空なら `default`）
- `DISPLAYDECK_LANG`: 画面の言語（`ja`・`en` など）
- `DISPLAYDECK_MOD_DATA`: MOD が使ってよい書き込み用のフォルダー
- `DISPLAYDECK_USER_AGENT`: 通信するときに使う User-Agent

**出力**: 標準出力に JSON を1つ（UTF-8）。うまくいかなかったときは `error` に短い説明を入れます。
- タイル: `{ "text": "57", "sub": "1D100", "error": null }`（`text` を大きく、`sub` を小さく出します）
- 天気: `{ "area": "Paris", "weather": "くもり", "icon": "cloud", "max": 12, "min": 5, "pop": 20, "tomorrow": false, "error": null }`
  （`icon` は `sun`・`partly`（晴れ時々くもり）・`cloud`・`rain`・`snow`・`thunder`・`fog`・`""`）

**決まり**
- DisplayDeck は窓を出さない指定で動かします（MOD が自分で窓を開くものは除きます）。タイルは 15 秒、天気は 20 秒で打ち切ります。
- 標準出力は 4,000 文字までしか読みません。設定の値は 200 文字までで、制御文字は空白にして渡します。
- フォルダーの中は 200 ファイル・20MB・8 階層までです。
- リンク（シンボリックリンク・ジャンクション）は使えません。

### ライセンス
MIT ライセンスです（LICENSE）。

---

## English

### What it is
A **MOD (a separately distributed add-on)** for DisplayDeck. Press the tile to roll the dice you set; the total is shown large and each roll small.

- Examples: `1D100`, `2D20`, `3D6+2`, `10D6-3` (upper/lower case and full-width characters are fine)
- 1–100 dice, 2–100000 faces, a bonus or penalty of 0–999999. Without a count it rolls one die (`D20` = `1D20`).
- With the setting left empty it rolls `1D100`.
- Each roll is listed for 2–6 dice, or for one die with a bonus/penalty (for a single plain die such as 1D100, and from 7 dice, just the total and the notation).
- Rolls use Windows' cryptographic random generator, without bias.
- No network access, no files written.

### Install
1. Download this repository (Code → Download ZIP).
2. Extract it and put the folder into DisplayDeck's MOD folder.
   - To open it, set a tile's type to "MOD (add-on)" in DisplayDeck's settings and press "Open the MOD folder".
     It is usually `%APPDATA%\DisplayDeck\mods\` (portable mode: `<DisplayDeck folder>\mods\`).
   - Any folder name works, but `mod.json` and `dice.ps1` must be directly inside it.
3. In DisplayDeck's settings:
   1. Select a tile and set its type to "MOD (add-on)".
   2. If the settings were open while you added the folder, press "Refresh list".
   3. Choose the MOD "Dice" and press "Verify and use this MOD".
   4. Enter the dice (e.g. `2D20`).
4. Press the tile on the touch screen to roll.
   - Use one tile per kind of roll.
   - A display name such as "1D100" helps tell the tiles apart.

### Icons (faces 1–6)
- For people who place several dice tiles, six icons with different faces are included (`dice-1.png` to `dice-6.png`).
- The default is the 5 face. To change it, press "Choose image…" under the tile's "Icon" and pick one from the MOD folder.

### Notes
- This MOD **may stop working at any time without notice** (for example, after a change in DisplayDeck).
- The author **accepts no responsibility whatsoever** for anything resulting from its use.
- Approval: DisplayDeck checks the contents of a MOD's folder before running it. If files inside are changed, added or removed, the MOD will not run until you approve it again (or the contents go back to a version you approved before).

### Making a MOD (this repository doubles as a sample)
A DisplayDeck MOD is one folder inside `mods`. Put `mod.json` and the file to run (`.ps1` or `.exe`) directly in that folder.

**mod.json**

| Field | Meaning |
|---|---|
| `id` | Lowercase letters, digits, `-`, `_` (up to 40). Must not clash with other MODs |
| `kind` | `tile` (a tile that runs when pressed) or `weather` (a weather source for the clock card) |
| `name` / `name_ja` | Display name (`name_ja` on a Japanese screen) |
| `version` | Version |
| `command` | File to run (`.ps1` or `.exe`) inside the folder |
| `icon` | Tile icon (`.png` or `.jpg`, optional; about 384×384) |
| `hosts` | Hosts it talks to (shown when approving; `[]` if none) |
| `settings` | Up to 3 fields: `key`, `label`, `label_ja`, `default` |
| Weather only | `intervalMinutes` (15–360), `credit`, `credit_ja`, `creditUrl` (https), `creditShort` (short credit shown next to the weather) |

**Passed by DisplayDeck (environment variables)**
- `DISPLAYDECK_SETTING_<KEY in upper case>`: the setting's value (`default` when empty)
- `DISPLAYDECK_LANG`: the UI language (`ja`, `en`, ...)
- `DISPLAYDECK_MOD_DATA`: a folder the MOD may write to
- `DISPLAYDECK_USER_AGENT`: User-Agent to use for network requests

**Output**: one JSON object on standard output (UTF-8). If something goes wrong, put a short message in `error`.
- Tile: `{ "text": "57", "sub": "1D100", "error": null }` (`text` large, `sub` small)
- Weather: `{ "area": "Paris", "weather": "Cloudy", "icon": "cloud", "max": 12, "min": 5, "pop": 20, "tomorrow": false, "error": null }`
  (`icon` is `sun`, `partly` (partly cloudy), `cloud`, `rain`, `snow`, `thunder`, `fog` or `""`)

**Rules**
- DisplayDeck starts MODs without a window (a MOD that opens its own window is another matter). Tiles are stopped after 15 seconds, weather after 20.
- Only the first 4,000 characters of standard output are read. Setting values are up to 200 characters; control characters are passed as spaces.
- Up to 200 files, 20 MB and 8 folder levels.
- Links (symbolic links, junctions) are not allowed.

### License
MIT (see LICENSE).
