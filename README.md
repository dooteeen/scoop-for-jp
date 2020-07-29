# Scoop for jp

日本語環境で使用するポータブルアプリやフォントなどを寄せ集めた[Scoop](https://github.com/lukesampson/scoop)の非公式Bucketです。  
非技術者含む幅広い日本人を対象した、`main`や`extras`など基本的なBucketの拡張にすることを目的としています。

※ このリポジトリは以下の後継になります。  
[rkbk60/scoop-for-jp](https://github.com/rkbk60/scoop-for-jp.git)

## 収録Manifest

### アプリ
- NTEmacs(更新終了): `emacs-nt`
- nkf: `nkf`
- KaoriYa版Vim: `vim-kaoriya`
- WinMerge 日本語版: `winmerge-jp` (手動更新のみ)

### フォント
- Cica: `cica`
- Myrica: `myrica`
- MyricaM: `myrica-m`
- Source Han Code JP: `source-han-code-jp`

### 収録終了
- Nyagos: mainバケット収録のため
- Ricty Diminished: ファイル配布終了のため

## 使い方

Bucket有効化
```
scoop bucket add jp https://github.com/dooteeen/scoop-for-jp
```

アプリの追加
```
scoop install vim-kaoriya
```

フォントの追加(全自動)
```
scoop install main/sudo
sudo scoop install cica -g
```

フォントの追加(半自動、展開先は環境変数`JP_FONT_DIR`で指定可能)
```
scoop install cica
explorer %USERPROFILE%\JpFonts
```

