class Uploader
  constructor: (@$browse_button, @$drag_area_ele, @$files)->
    data = @$browse_button.data()
    @domain = data['domain']
    @basepath = data['basepath']
    @file_progresses = {}
    @_init()
    @_init_paste_event()

  _init: ()->
    that = this
    @qiniu = Qiniu.uploader
      runtimes: 'html5,flash,html4'
      browse_button: that.$browse_button.get(0),
      uptoken_url: '/file_entities/uptoken',
      domain: @domain,
      max_file_size: '100mb',
      max_retries: 1,
      dragdrop: true,
      drop_element: that.$drag_area_ele.get(0),
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

  _init_paste_event: ()->
    # 通过粘贴上传文件
    ###
      粘贴有六种情况：
      1. [√] 在 chrome 下通过软件复制图像数据
      2. [√] 在 chrome 下右键复制网页图片
      3. [×] 在 chrome 下粘贴磁盘文件句柄 ......

      4. [√] 在 firefox 下通过软件复制图像数据
      5. [√] 在 firefox 下右键复制网页图片
      6. [√] 在 firefox 下粘贴磁盘文件句柄
    ###


    # 粘贴剪贴板内容 (chrome)
    # 在 firefox 下，需要在页面放置一个隐藏的 contenteditable = true 的 dom
    paste_dom = jQuery '<div contenteditable></div>'
      .css
        'position': 'absolute'
        'left': -99999
        'top': -99999
      .appendTo jQuery(document.body)
      .focus()

    that = this
    jQuery(document).off 'paste'
    jQuery(document).on 'paste', (evt)=>
      # chrome
      arr = (evt.clipboardData || evt.originalEvent.clipboardData)?.items
      if arr?.length
        return @_deal_chrome_paste arr

      # firefox
      paste_dom.html('').focus()
      setTimeout =>
        paste_dom.find('img').each ->
          $img = jQuery(this)
          that._deal_firefox_paste $img

  _deal_chrome_paste: (arr)->
    console.log 'chrome paste'
    for i in arr
      if i.type.match(/^image\/\w+$/) 
        file = i.getAsFile()
        file.name = "paste-#{(new Date).valueOf()}.png"
        @qiniu.addFile(file) if file

  _deal_firefox_paste: ($img)->
    console.log 'firefox paste'
    src = $img.attr 'src'
    if src.match /^data\:image\//
      blob = dataURLtoBlob src
      blob.name = "paste-#{(new Date).valueOf()}.png"
      @qiniu.addFile(blob)
      return

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

    if res.kind == "image"
      @$file.find('img').attr('src', res.url)
      @$file.find('img').show()
    else
      @$file.find('img').hide()

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
  if jQuery('.page-file-entities .action a.upload').length > 0
    ele = jQuery('.page-file-entities .action a.upload')
    files = jQuery('.page-file-entities .files')
    drag_area = jQuery('.page-file-entities .drag-area')
    new Uploader(ele, drag_area, files)
