image-service
=============

启动sidekiq队列

```bash
$ bundle exec sidekiq -q carrierwave -c 2 -r ./lib/app.rb
```
