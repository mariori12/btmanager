## 開発コマンド一覧

```sh
# RSpecによる自動テストを実行する
bin/rspec
# RuboCopによる静的解析を実行する
bundle exec rubocop
# HTML Beautifierによるerbフォーマットを実行する
echo 'Run htmlbeautifier...'; for file in $(find . -name '*.erb'); do echo $file; bundle exec htmlbeautifier --stop-on-errors --keep-blank-lines 1 $file; done
```
