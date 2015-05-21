namespace :uploader_test_files do
  desc "上传测试文件至七牛bucket"
  task images: :environment do
    put_policy = Qiniu::Auth::PutPolicy.new(
        ENV['QINIU_BUCKET'],     # 存储空间
        #key,        # 最终资源名，可省略，即缺省为“创建”语义
        #expires_in, # 相对有效期，可省略，缺省为3600秒后 uptoken 过期
        #deadline    # 绝对有效期，可省略，指明 uptoken 过期期限（绝对值），通常用于调试
    )
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,     # 上传策略
        "spec/photos/first.jpg",     # 本地文件名
        "/i/first.jpg",            # 最终资源名，可省略，缺省为上传策略 scope 字段中指定的Key值
    )
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,     # 上传策略
        "spec/photos/second.jpg",     # 本地文件名
        "/i/second.jpg",            # 最终资源名，可省略，缺省为上传策略 scope 字段中指定的Key值
    )
  end

end
