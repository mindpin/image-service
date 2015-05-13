jQuery(document).on 'ready page:load', ->
  if jQuery('.page-images .action a.upload').length > 0
    data = jQuery('.page-images .action a.upload').data()
    domain = data['domain']
    basepath = data['basepath']
    filename = jQuery('.page-images .action .filename')
    progress = jQuery('.page-images .action .progress')
    success  = jQuery('.page-images .action .success')

    uploader = Qiniu.uploader
      runtimes: 'html5,flash,html4'
      browse_button: 'upload_btn',
      uptoken_url: '/images/uptoken',
      domain: domain,
      max_file_size: '100mb',           #最大文件体积限制
      max_retries: 3,                   #上传失败最大重试次数
      chunk_size: '4mb',                #分块上传时，每片的体积
      auto_start: true,                 #选择文件后自动上传，若关闭需要自己绑定事件触发上传
      x_vars:
        origin_file_name: (up, file)->
          file.name
      init: 
        FilesAdded: (up, files)->
          plupload.each files, (file)->
            #文件添加进队列后,处理相关的事情
        BeforeUpload: (up, file)->
          #每个文件上传前,处理相关的事情
            filename.show()
            filename.text("正在准备上传 #{file.name}")
            progress.show()
            progress.text("请稍等...")
        UploadProgress: (up, file)-> 
          #每个文件上传时,处理相关的事情
          chunk_size = plupload.parseSize(this.getOption('chunk_size'));
          progress.text "当前进度 #{file.percent}%，速度 #{up.total.bytesPerSec}，#{chunk_size}"
        FileUploaded: (up, file, info)->
          domain = up.getOption('domain');
          res = jQuery.parseJSON(info);
          console.log res
          success.text("上传成功，访问地址 #{res.url}")
          success.show()
          filename.hide()
          progress.hide()
          #每个文件上传成功后,处理相关的事情
          #其中 info 是文件上传成功后，服务端返回的json，形式如
          # // {
          # //    "hash": "Fh8xVqod2MQ1mocfI4S4KpRL6D98",
          # //    "key": "gogopher.jpg"
          # //  }
          # // 参考http://developer.qiniu.com/docs/v6/api/overview/up/response/simple-response.html
          # // var domain = up.getOption('domain');
          # // var res = parseJSON(info);
          # // var sourceLink = domain + res.key; 获取上传成功后的文件的Url
        Error: (up, err, errTip)->
          #上传出错时,处理相关的事情
          console.log("Error")
          console.log(up)
          console.log(err)
          console.log(errTip)
        UploadComplete: ()->
          #队列文件处理完毕后,处理相关的事情
        Key: (up, file)->
          ext = file.name.split(".").pop()
          "/#{basepath}/#{jQuery.randstr()}.#{ext}"
# // domain 为七牛空间（bucket)对应的域名，选择某个空间后，可通过"空间设置->基本设置->域名设置"查看获取
# // uploader 为一个plupload对象，继承了所有plupload的方法，参考http://plupload.com/docs