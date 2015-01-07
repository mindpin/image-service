image-service
=============
开发环境运行方法：

```
git submodule init
git submodule update

cp config/mongoid.yml.example config/mongoid.yml
cp config/env.yml.example config/env.yml
# 配置 env.yml 内容

bundle
bundle exec rackup
```

控制台：
irb -r ./lib/app.rb
