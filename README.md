image-service
=============
开发环境运行方法：

```
git submodule init
git submodule update

cp config/mongoid.yml.example config/mongoid.yml
cp config/env.yml.example config/env.yml
# 配置 env.yml 内容


rake invitations:create count=5
# 生成邀请码


bundle
bundle exec rackup
```

oauth callback 地址为
```
http://www.xxx.com/auth/qq/callback
http://www.xxx.com/auth/github/callback
http://www.xxx.com/auth/weibo/callback
```

控制台：
irb -r ./lib/app.rb
