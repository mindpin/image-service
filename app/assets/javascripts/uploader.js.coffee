class Uploader
  constructor: (@$browse_button, @$files)->
    @$browse_button_id = @$browse_button.attr("id")
    data = @$browse_button.data()
    @domain = data['domain']
    @basepath = data['basepath']
    @file_progresses = {}
    @_init()

  _init: ()->
    that = this
    Qiniu.uploader
      runtimes: 'html5,flash,html4'
      browse_button: 'upload_btn',
      uptoken_url: '/images/uptoken',
      domain: @domain,
      max_file_size: '100mb',           
      max_retries: 1,                   
      chunk_size: '4mb',                
      auto_start: true,               
      x_vars:
        origin_file_name: (up, file)->
          file.name
      init: 
        FilesAdded: (up, files)->
          plupload.each files, (file)->
            # 同时选择多个文件时才会触发
        BeforeUpload: (up, file)->
          that.file_progresses[file.id] = new FileProgress(that.$files, file)
          that.file_progresses[file.id].start_upload()
        UploadProgress: (up, file)-> 
          console.log file
          chunk_size = plupload.parseSize(this.getOption('chunk_size'));
          that.file_progresses[file.id].refresh_progress()
          # progress.text "当前进度 #{file.percent}%，速度 #{up.total.bytesPerSec}，#{chunk_size}"
        FileUploaded: (up, file, info)->
          that.file_progresses[file.id].uploaded(info)
        Error: (up, err, errTip)->
          that.file_progresses[err.file.id].upload_error()
        UploadComplete: ()->
          #队列文件处理完毕后,处理相关的事情
        Key: (up, file)->
          # // domain 为七牛空间（bucket)对应的域名，选择某个空间后，可通过"空间设置->基本设置->域名设置"查看获取
          # // uploader 为一个plupload对象，继承了所有plupload的方法，参考http://plupload.com/docs
          ext = file.name.split(".").pop()
          "/#{that.basepath}/#{jQuery.randstr()}.#{ext}"


class FileProgress
  constructor: (@$files_ele, @file)->
    if @$files_ele.find("#file_#{@file.id}").length == 0
      @_add_dom()
    @$file = @$files_ele.find("#file_#{@file.id}")

  refresh_progress: ->
    @$file.find('.progress').text("#{@file.percent}%")

  uploaded: (info)->
    res = jQuery.parseJSON(info);
    @$file.find('.progress').text("上传成功")

    @$file.find('img').attr('src', res.url)
    @$file.find('img').show()

    @$file.find('a.url').attr('href', res.url)
    @$file.find('a.url').text(res.url)
    @$file.find('a.url').show()

  upload_error: ->
    @$file.find('.progress').text("上传出错")

  start_upload: ->
    @$file.find('.progress').text("开始上传")

  _add_dom: ()->
    jQuery("
      <div id='file_#{@file.id}' class='file'>
        <div class='name'>#{@file.name}</div>
        <div class='size'>文件大小:#{@file.size}K</div>
        <div class='progress'>正在准备上传</div>
        <img src='' style='display:none;'>
        <a class='url' style='display:none;' href=''></a>
      </div>
    ").appendTo(@$files_ele)

jQuery(document).on 'ready page:load', ->
  if jQuery('.page-images .action a.upload').length > 0
    ele = jQuery('.page-images .action a.upload')
    files = jQuery('.page-images .files')
    new Uploader(ele, files)