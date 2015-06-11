###
  给浏览器增加图片粘贴事件
###

window.PasteImage = class PasteImage
  constructor: (@upload_func)->
    # 上传回调事件
    @upload_func ?= (file_or_blob)->
      console.log '请注册自定义的粘贴上传处理方法'
      console.log file_or_blob

    # 通过粘贴上传图片文件
    ###
      粘贴有六种情况：
      1. [√] 在 chrome 下通过软件复制图像数据
      2. [√] 在 chrome 下右键复制网页图片
      3. [×] 在 chrome 下粘贴磁盘文件句柄 ......

      4. [√] 在 firefox 下通过软件复制图像数据
      5. [√] 在 firefox 下右键复制网页图片
      6. [√] 在 firefox 下粘贴磁盘文件句柄
    ###


    ###
      在 firefox 下，需要在页面放置一个隐藏的 dom
      并设置属性为 contenteditable = true
      方能触发粘贴事件
    ###
    @prepare_for_firefox()

    # 注册粘贴事件
    jQuery(document).off 'paste'
    jQuery(document).on 'paste', (evt)=>
      # chrome
      arr = (evt.clipboardData or 
        evt.originalEvent.clipboardData)?.items
      if arr?.length
        return @_deal_chrome_paste arr

      # firefox
      that = this
      paste_dom.html('').focus()
      setTimeout =>
        paste_dom.find('img').each ->
          $img = jQuery(this)
          that._deal_firefox_paste $img


  prepare_for_firefox: ->
    paste_dom = jQuery '<div contenteditable></div>'
      .css
        'position': 'absolute'
        'left': -99999
        'top': -99999
      .appendTo jQuery(document.body)
      .focus()


  _deal_chrome_paste: (arr)->
    console.debug 'chrome paste'
    for i in arr
      if i.type.match(/^image\/\w+$/) 
        file = i.getAsFile()
        @upload_func file


  _deal_firefox_paste: ($img)->
    console.debug 'firefox paste'
    src = $img.attr 'src'
    if src.match /^data\:image\//
      blob = dataURLtoBlob src
      @upload_func blob

    # 根据网址从远程读取图片，暂时先不实现
    # if src.match /http\:\/\//
      # blob = getImageBlob src
      # blob.name = "remote-#{(new Date).valueOf()}.png"
      # @upload blob
      # @upload_remote_url src