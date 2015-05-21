# 第一次运行需要做的准备
```
cp mongoid.yml.example mongoid.yml
cp application.yml.example application.yml
```

### 测试
由于某些测试需要上传图片至七牛bucket中才能正常完成，所以需要先执行一个task，命令如下：
```
rake uploader_test_files:images
```
