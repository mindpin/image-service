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

  desc "创建测试用 oss file_entitiy"
  task oss_file_entitiies: :environment do
    infos = [
      {ave: "#482A19", height: 680, token: "i4Wbvapm", width: 1024},
      {ave: "#900A06", height: 878, token: "wx8Bq1E6", width: 1024},
      {ave: "#563B1E", height: 426, token: "tix7qaCf", width: 640},
      {ave: "#5A493C", height: 640, token: "bymfsoh5", width: 640},
      {ave: "#D0604D", height: 720, token: "ZMoAbk12", width: 720},
      {ave: "#9C7249", height: 640, token: "TdDAbHER", width: 640},
      {ave: "#51371F", height: 640, token: "yo8613J9", width: 640},
      {ave: "#90A872", height: 640, token: "X8LhkEPT", width: 640},
      {ave: "#4E331D", height: 525, token: "gjhLX2HZ", width: 600},
      {ave: "#BA7074", height: 720, token: "NjbKPqT2", width: 720},
      {ave: "#80632D", height: 640, token: "i6FYzfMS", width: 640},
      {ave: "#435464", height: 675, token: "qZnvgddO", width: 477, ext: 'jpg'},
      {ave: "#40BA9F", height: 467, token: "C8p1BZ3m", width: 477, ext: 'jpg'},
      {ave: "#2C3338", height: 675, token: "sFokcStZ", width: 477, ext: 'jpg'},
      {ave: "#BA7A68", height: 467, token: "D4Tkko8b", width: 477, ext: 'jpg'},
      {ave: "#80632D", height: 467, token: "GvadbyxR", width: 477, ext: 'jpg'},
      {ave: "#676968", height: 467, token: "wVAEKa0F", width: 477, ext: 'jpg'},
      {ave: "#656360", height: 467, token: "DhxsQ6lq", width: 477, ext: 'jpg'},
      {ave: "#020203", height: 467, token: "BqRxa0pO", width: 477, ext: 'jpg'},
      {ave: "#0D1D28", height: 675, token: "QQXGPAWH", width: 477, ext: 'jpg'},
      {ave: "#3E3C36", height: 467, token: "CwifcMsv", width: 477, ext: 'jpg'},
      {ave: "#4C6861", height: 467, token: "CcwraYrJ", width: 477, ext: 'jpg'},
      {ave: "#8E644D", height: 675, token: "bWwThUfi", width: 477, ext: 'jpg'},
      {ave: "#E2D67C", height: 400, token: "sEmGzY2U", width: 600},
      {ave: "#FDCC97", height: 400, token: "o3LntKdn", width: 600},
      {ave: "#E59370", height: 400, token: "ka3r5ZC4", width: 600},
      {ave: "#809D65", height: 400, token: "ceCnw6QI", width: 600},
      {ave: "#D69D4E", height: 400, token: "l4U68CQt", width: 600},
      {ave: "#E09C68", height: 400, token: "SCAHZ1j1", width: 600},
      {ave: "#AAB87D", height: 400, token: "h6NjVtue", width: 600},
      {ave: "#CCCC88", height: 400, token: "dGbioNC8", width: 600},
      {ave: "#D8AA58", height: 400, token: "qEe9mLR0", width: 600},
      {ave: "#9C8582", height: 300, token: "Z7hcm6aq", width: 300},
      {ave: "#CAC6C0", height: 520, token: "n5vvUwxB", width: 520}
    ]

    user = User.first
    infos.each do |info|
      ext = info[:ext] || 'png'

      FileEntity.create!(
        original: "paste-#{randstr}.#{ext}", 
        token: info[:token], 
        mime: "image/png", 
        meta: {
          "major_color" => {
            "rgba" => "rgba(0,0,0,0)", 
            "hex"  => info[:ave]
          }, 
          "height"   => info[:height], 
          "width"    => info[:width], 
          "filesize" => 219350
        },
        is_oss: true,
        kind: :image,
        user: user
      )
    end

    p "import success!"
  end

end
