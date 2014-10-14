# http://stackoverflow.com/questions/10253663/how-to-detect-the-dragleave-event-in-firefox-when-dragging-outside-the-window
# 一个小扩展，用来更优雅地处理文件拖拽
jQuery.fn.draghover = (options)->
  this.each ->
    collection = jQuery()
    self = jQuery(this)

    self.on 'dragenter', (evt)->
      evt.stopPropagation()
      evt.preventDefault()
      if collection.length is 0
        self.trigger 'draghoverstart'
      collection = collection.add evt.target

    self.on 'dragleave drop', (evt)->
      evt.stopPropagation()
      evt.preventDefault()
      collection = collection.not evt.target
      if collection.length is 0
        self.trigger 'draghoverend'

    self.on 'dragover', (evt)->
      evt.stopPropagation()
      evt.preventDefault()

# 跨域情况下似乎不能用，先注掉
# getImageBlob = (url)->
#   r = new XMLHttpRequest()
#   r.open "GET", url, false
#   # 详细请查看: https://developer.mozilla.org/En/XMLHttpRequest/Using_XMLHttpRequest#Receiving_binary_data
#   # XHR binary charset opt by Marcus Granado 2006 [http://mgran.blogspot.com]
#   r.overrideMimeType 'text/plainl; charset=x-user-defined'
#   r.send null
#   blob = binaryToBlob r.responseText
#   blob.fileType = 'image/png'
#   blob

class ImageUrlFormatter
  constructor: (@url)->
    @html = "<img src='#{@url}' />"
    @markdown = "![](#{@url})"

  clip_url: (width, height)->
    "#{@url}@#{width}w_#{height}h_1e_1c.png"



class IndexPage
  constructor: (@$el)->
    @$file_input = @$el.find('form.upload input[type=file]')
    @$uploading_list = @$el.find('.uploading-list')

    @bind_events()

  bind_events: ->
    that = @

    # 禁止拖拽页面元素
    jQuery(document).on 'dragstart', (evt)=>
      evt.stopPropagation()
      evt.preventDefault()


    # 选择文件上传
    @$file_input.on 'change', =>
      for file in @$file_input[0].files
        @upload file


    # 上传图标
    @$el.delegate 'a.btn-upload', 'click', =>
      @$file_input.trigger 'click'


    # 拖拽文件
    dragging = 0
    jQuery(window)
      .draghover()
      .on 'draghoverstart', (evt)=>
        jQuery(document.body).addClass 'drag-over'
      .on 'draghoverend', (evt)=>
        jQuery(document.body).removeClass 'drag-over'

    jQuery(window).on 'drop', (evt)=>
      evt.stopPropagation()
      evt.preventDefault()
      jQuery(document.body).removeClass 'drag-over'
      for file in evt.originalEvent.dataTransfer.files
        @upload file


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


    # 选中 input 内容
    @$uploading_list.delegate 'input', 'click', ->
      jQuery(this).select()


    # 关闭 uploading
    @$uploading_list.delegate '.op.close', 'click', ->
      $uploading = jQuery(this).closest '.uploading'
      $uploading.hide 400, -> 
        $uploading.remove()
        if that.$uploading_list.find('.uploading:not(.template)').length is 0
          that.$el.removeClass 'uploading'


  _deal_firefox_paste: ($img)->
    console.log 'firefox paste'
    src = $img.attr 'src'
    if src.match /^data\:image\//
      blob = dataURLtoBlob src
      blob.name = "paste-#{(new Date).valueOf()}.png"
      @upload blob
      return

    if src.match /http\:\/\//
      # blob = getImageBlob src
      # blob.name = "remote-#{(new Date).valueOf()}.png"
      # @upload blob
      @upload_remote_url src


  _deal_chrome_paste: (arr)->
    console.log 'chrome paste'
    for i in arr
      if i.type.match(/^image\/\w+$/) 
        file = i.getAsFile()
        @upload(file) if file



  # 上传指定文件
  upload: (file)->
    file.name ?= "paste-#{(new Date).valueOf()}.png"

    @$el.addClass 'uploading'
    $uploading = @_generate_uploading_el(file.name)
    jQuery.ajax
      type        : 'POST'
      contentType : false
      processData : false
      url         : '/images'
      data        : @_make_file_data(file)
      success: (res)=>
        @_deal_res res, $uploading


  # 上传 base64 信息
  # 因为找到了 canvas-to-blob 这个库，因此用了更简单的方法来上传文件
  # 此方法和服务端相应的处理方法都没有被用到，但保留
  upload_base64: (base64_string)->
    filename = "paste-#{(new Date).valueOf()}.png"

    @$el.addClass 'uploading'
    $uploading = @_generate_uploading_el(filename)
    jQuery.ajax
      type : 'POST'
      url  : '/images'
      data : 
        'base64': base64_string
      success: (res)=>
        @_deal_res res, $uploading


  # 传远程 url，服务器读取远程 url
  upload_remote_url: (remote_url)->
    filename = "remote-#{(new Date).valueOf()}.png"

    @$el.addClass 'uploading'
    $uploading = @_generate_uploading_el(filename)
    jQuery.ajax
      type : 'POST'
      url  : '/images'
      data : 
        'remote_url': remote_url
      success: (res)=>
        @_deal_res res, $uploading


  _make_file_data: (file)->
    data = new FormData
    data.append "file", file, file.name
    return data


  _generate_uploading_el: (filename)->
    @$uploading_list.find('.template').clone()
      .removeClass 'template'
      .addClass 'running'
      .find('.filename').text(filename).end()
      .find('input.url').val('').end()
      .find('a.image')
        .attr('href', 'javascript:;')
        .find('.ibox').html('').end()
      .end()
      .prependTo @$uploading_list
      .hide()
      .show 400

  _deal_res: (res, $uploading)->
    iuf = new ImageUrlFormatter res.url

    $uploading
      .removeClass 'running'
      .find('input.url.i').val(iuf.url).end()
      .find('input.url.h').val(iuf.html).end()
      .find('input.url.m').val(iuf.markdown).end()
      .find('a.image').attr 'href', iuf.url

    jQuery '<img>'
      .attr 'src', iuf.clip_url(150, 150)
      .hide().fadeIn()
      .appendTo $uploading.find('a.image .ibox')



jQuery ->
  new IndexPage jQuery('.page-index') if jQuery('.page-index').length