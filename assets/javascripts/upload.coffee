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


class IndexPage
  constructor: (@$el)->
    @$file_input = @$el.find('form.upload input[type=file]')
    
    @bind_events()

  bind_events: ->
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
      paste_dom.focus()

      setTimeout =>
        if ($img = paste_dom.find('img')).length
          @_deal_firefox_paste $img
          return
        
      arr = (evt.clipboardData || evt.originalEvent.clipboardData)?.items
      @_deal_chrome_paste arr if arr

  _deal_firefox_paste: ($img)->
    console.log 'firefox paste'

    jQuery.ajax
      type : "POST"
      url         : '/images'
      data        : 
        'base64': $img.attr('src')

  _deal_chrome_paste: (arr)->
    console.log 'chrome paste'
    for i in arr
      if i.type.match(/^image\/\w+$/) 
        file = i.getAsFile()
        @upload(file, "image-#{(new Date).valueOf()}.png") if file



  # 上传指定文件
  upload: (file, name)->
    console.log file
    file.name = name if name
    uploader = new FileUploader(file)

    uploader.before ->
      # $image_upload.addClass("moveup")
      # $uploading = $uploading_template.clone()

      # file.elm = $uploading

      # $uploading.find(".filename").text(file.name)
      # $uploading_list.fadeIn()
      # $uploading_list.append($uploading)
      # $uploading.fadeIn()

    deferred = uploader.request("/images")

    deferred.done (res)->
      file.elm.find("i").fadeOut()
      file.elm.find("a").attr("href", "/images/#{res.filename.split('.')[0]}").fadeIn()



class FileUploader
  constructor: (@file)->
    @data = new FormData
    @data.append "file", @file, @file.name

  before: (fn)->
    @before = fn

  request: (url)->
    @before()
    jQuery.ajax
      type : "POST"
      contentType : false
      processData : false
      url         : url
      data        : @data



jQuery ->
  new IndexPage jQuery('.page-index') if jQuery('.page-index').length