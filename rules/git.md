---
description: git コマンドを実行するときに呼ばれます。Gitの使い方やコミットメッセージを定義します。
globs:
alwaysApply: false
---

作業着手前にこのファイルを読み込んだことを、定義された人格に沿って**必ず**伝えます。

# Gitを使ったバージョン管理

このファイルではGitを使うときの手順を定義します。

## コミットメッセージ

[Angularの規約](mdc:https:/github.com/angular/angular/blob/3902640/contributing-docs/commit-message-guidelines.md)に準拠します。

特に指示がなければ、**英語**でメッセージを作成します。 そのメッセージにした理由は**日本語**で説明します。

- typeは `git --no-pager diff` から判断
- scopeは影響範囲を記載
- 命令形で変更内容が伝わる簡潔なメッセージ
- コミット後はtype/scopeをリセット
- 変更内容に応じて適切なtype/scopeを選定

## 複数行のコミットメッセージ

- CLI上では直接改行できないため、`-m` オプションを複数回使用
  ```sh
  git commit -m "feat(scope): add new feature" -m "Add description about the feature"
  ```
- 一行目は件名（50文字以内）、二行目以降は本文
- メッセージ全体で100文字以内に収める
- 本文は「なぜ」「何のために」「どのように」を説明する
- 本文が必要ない場合は件名のみにする

## Gitコマンドを使う際の注意

入力の待機防止用に `--no-pager` オプションを使用します。

```sh
git --no-pager diff
```
