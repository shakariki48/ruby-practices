# 05.ls

## テスト実行手順

```sh
git clone https://github.com/shakariki48/ruby-practices.git

cd ruby-practices

docker run -it --rm -v `pwd`:/ruby-practices --workdir /ruby-practices/05.ls/test ruby:3.0-bullseye ruby ls_test.rb
```
